# Third-party code notice

The MATLAB files in this folder are **derived from** the repository

> **heyinUCB/IQCbased_ImitationLearning**
> <https://github.com/heyinUCB/IQCbased_ImitationLearning>
> Copyright (c) 2021 heyinUCB — released under the MIT License

which accompanies

> H. Yin, P. Seiler, and M. Arcak, "Stability Analysis Using Quadratic
> Constraints for Systems with Neural Network Controllers," *IEEE Transactions
> on Automatic Control*, vol. 67, no. 4, pp. 1980–1987, 2022.
> (and the companion: H. Yin, P. Seiler, M. Jin, M. Arcak, "Imitation Learning
> with Stability and Safety Guarantees," *IEEE L-CSS*, vol. 6, pp. 409–414, 2021.)

The MIT License permits reuse, modification, and redistribution provided the
copyright and permission notice are retained. That notice is reproduced
verbatim in [`UPSTREAM_LICENSE`](UPSTREAM_LICENSE) in this folder.

## Files

| File | Origin |
|------|--------|
| `iqc_roa_2d_example.m` | Adaptation of the upstream `pendulum_explicit_MPC` IQC/ROA analysis script, re-targeted to the 2-D LTI example of *this* paper (discretized `A`, `B`). Produces the "IQC method [3]" row of Table I. |
| `nnclosedloop.m`       | Upstream helper (closed-loop simulation of the NN controller), used by the script above. |

## What was changed

Only the plant data and the neural-network being analyzed were changed, so that
the IQC method runs on the same 2-D example used elsewhere in this repository.
The IQC/QC + Lyapunov SDP formulation is unchanged from the upstream work.

## If you re-publish

Keep `UPSTREAM_LICENSE` alongside these files. If you prefer not to vendor the
code at all, delete this folder and instead link to the upstream repository from
`baseline/README.md`; both are acceptable under the MIT terms.
