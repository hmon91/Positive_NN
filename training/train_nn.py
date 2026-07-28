#!/usr/bin/env python3
"""Train a bias-free, tanh feedforward network to imitate an expert controller.

The network has NO biases and uses tanh on every hidden layer with a linear
output, exactly the class of controllers analysed in

    H. Montazeri Hedesh and M. Siami, "Ensuring Both Positivity and Stability
    Using Sector-Bounded Nonlinearity for Systems with Neural Network
    Controllers."

Training data are the (state, input) pairs produced by ``main_example.m``
(an LQR expert), stored as CSV under ``data/training``. Trained weights are
written as ``W1.csv, W2.csv, ...`` (comma-delimited, no header) in the
``n_i x n_{i-1}`` orientation expected by the MATLAB code, i.e. each row of
``Wi.csv`` is one neuron's incoming weights.

Example
-------
Reproduce the paper's 10/15/15/1 network::

    python train_nn.py \
        --states ../data/training/lqr_states.csv \
        --inputs ../data/training/lqr_inputs.csv \
        --hidden 10 15 15 \
        --out ../data/weights/net_10_15_15_1 \
        --epochs 500
"""

import argparse
import os

import numpy as np


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    here = os.path.dirname(os.path.abspath(__file__))
    p.add_argument("--states", default=os.path.join(here, "..", "data",
                   "training", "lqr_states.csv"),
                   help="CSV of state samples, shape (N, n_x).")
    p.add_argument("--inputs", default=os.path.join(here, "..", "data",
                   "training", "lqr_inputs.csv"),
                   help="CSV of control targets, shape (N, n_u).")
    p.add_argument("--hidden", type=int, nargs="+", default=[10, 15, 15],
                   help="Hidden-layer widths (default: 10 15 15).")
    p.add_argument("--out", default=os.path.join(here, "..", "data",
                   "weights", "net_trained"),
                   help="Directory to write W1.csv, W2.csv, ...")
    p.add_argument("--epochs", type=int, default=500)
    p.add_argument("--batch-size", type=int, default=32)
    p.add_argument("--lr", type=float, default=1e-3)
    p.add_argument("--seed", type=int, default=0)
    return p.parse_args()


def build_model(n_in: int, hidden, n_out: int, lr: float):
    # Imported lazily so that --help works without TensorFlow installed.
    from tensorflow import keras
    from tensorflow.keras.layers import Dense
    from tensorflow.keras.models import Sequential

    model = Sequential(name="bias_free_ffnn")
    for i, width in enumerate(hidden):
        kwargs = {"activation": "tanh", "use_bias": False, "name": f"dense_{i+1}"}
        if i == 0:
            kwargs["input_dim"] = n_in
        model.add(Dense(width, **kwargs))
    model.add(Dense(n_out, use_bias=False, name="dense_output"))
    model.compile(optimizer=keras.optimizers.RMSprop(learning_rate=lr),
                  loss="mse")
    return model


def main() -> None:
    args = parse_args()
    np.random.seed(args.seed)

    xs = np.atleast_2d(np.loadtxt(args.states, delimiter=","))
    us = np.atleast_2d(np.loadtxt(args.inputs, delimiter=","))
    if us.shape[0] == 1 and us.shape[1] == xs.shape[0]:
        us = us.T                      # accept a (1, N) row vector of targets
    print(f"Loaded {xs.shape[0]} samples: states {xs.shape}, inputs {us.shape}")

    import tensorflow as tf
    tf.random.set_seed(args.seed)

    model = build_model(xs.shape[1], args.hidden, us.shape[1], args.lr)
    model.summary()
    model.fit(xs, us, epochs=args.epochs, batch_size=args.batch_size,
              verbose=2, validation_split=0.0)

    os.makedirs(args.out, exist_ok=True)
    for i, layer in enumerate(model.layers, start=1):
        # Keras Dense stores weights as (n_in, n_out); transpose to (n_out,
        # n_in) so the MATLAB code can compute v_i = W_i * w_{i-1}.
        w = np.transpose(layer.get_weights()[0])
        path = os.path.join(args.out, f"W{i}.csv")
        np.savetxt(path, w, delimiter=",", fmt="%.8g")
        print(f"  wrote {path}  ({w.shape[0]} x {w.shape[1]})")

    # Quick sanity check: the sector bound Gamma2 = prod(|W_i|).
    g2 = np.abs(np.transpose(model.layers[0].get_weights()[0]))
    for layer in model.layers[1:]:
        g2 = np.abs(np.transpose(layer.get_weights()[0])) @ g2
    print(f"Sector bound Gamma2 = {g2.ravel()}")


if __name__ == "__main__":
    main()
