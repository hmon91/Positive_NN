function [Gamma1, Gamma2] = sector_bound(W, actSector)
%SECTOR_BOUND  Sector bound of a bias-free feedforward neural network.
%
%   [GAMMA1, GAMMA2] = SECTOR_BOUND(W) computes the elementwise sector
%   bounds Gamma1 and Gamma2 of a fully connected, bias-free FFNN whose
%   weight matrices are given as the cell array W = {W1, W2, ..., WL},
%   ordered from input to output.  The scalar activation is assumed to lie
%   in the sector [0, 1] (true for tanh and ReLU), so the constant c = 1.
%
%   [GAMMA1, GAMMA2] = SECTOR_BOUND(W, ACTSECTOR) uses a custom activation
%   sector ACTSECTOR = [a1, a2]; the constant is c = max(|a1|, |a2|).
%
%   This implements Theorem 2 of
%     H. Montazeri Hedesh and M. Siami, "Ensuring Both Positivity and
%     Stability Using Sector-Bounded Nonlinearity for Systems with Neural
%     Network Controllers."
%
%       Gamma2 =  c^(L-1) * |WL| * ... * |W2| * |W1|
%       Gamma1 = -Gamma2
%
%   so that, for every non-negative input z >= 0,
%
%       Gamma1 * z  <=  pi(z)  <=  Gamma2 * z          (elementwise)
%
%   where pi(.) is the network map and L = numel(W) is the number of
%   weight matrices (i.e. hidden layers + 1).  Gamma1 and Gamma2 are
%   (m x p), with p the input dimension and m the output dimension.
%
%   Example:
%       W = load_weights('../data/weights/net_10_20_1');
%       [G1, G2] = sector_bound(W);        % tanh, sector [0 1]
%
%   See also VERIFY_STABILITY, NN_FORWARD, LOAD_WEIGHTS.

    if nargin < 2 || isempty(actSector)
        actSector = [0, 1];            % tanh / ReLU
    end
    c = max(abs(actSector));

    L = numel(W);
    absProd = abs(W{1});
    for i = 2:L
        absProd = abs(W{i}) * absProd;
    end

    Gamma2 =  c^(L-1) * absProd;
    Gamma1 = -Gamma2;
end
