function u = nn_forward(W, z, act)
%NN_FORWARD  Evaluate a bias-free feedforward neural network.
%
%   U = NN_FORWARD(W, Z) evaluates the bias-free FFNN with weight cell
%   array W = {W1, ..., WL} at input Z using tanh activations on every
%   hidden layer and a linear output layer:
%
%       w = z;  w = tanh(W1*w);  ...;  w = tanh(W_{L-1}*w);  u = WL*w.
%
%   U = NN_FORWARD(W, Z, ACT) uses the function handle ACT as the hidden
%   activation (default @tanh).
%
%   Z may be a column vector (p x 1) or a matrix of stacked column samples
%   (p x N), in which case U is (m x N).
%
%   See also SECTOR_BOUND, LOAD_WEIGHTS.

    if nargin < 3 || isempty(act), act = @tanh; end
    L = numel(W);
    w = z;
    for i = 1:L-1
        w = act(W{i}*w);
    end
    u = W{L}*w;
end
