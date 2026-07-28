%% MAIN_EXAMPLE
%  Reproduces the numerical-example pipeline of
%    H. Montazeri Hedesh and M. Siami, "Ensuring Both Positivity and
%    Stability Using Sector-Bounded Nonlinearity for Systems with Neural
%    Network Controllers."
%
%  Steps:
%    1. Define the LTI plant and an LQR expert controller.
%    2. Generate imitation-learning data (states z >= 0, targets u = K z).
%    3. Train the NN in Python (see ../training/train_nn.py) and export
%       its weights as W1.csv, W2.csv, ... into a folder under data/weights.
%    4. Load the weights and compute the sector bound  (Theorem 2).
%    5. Verify closed-loop stability                    (Theorem 3).
%
%  Afterwards run fig_sector_bound.m and fig_closed_loop.m for the figures.
%
%  NOTE ON THE SHIPPED WEIGHTS: the two networks under data/weights are
%  experimental snapshots and do NOT reproduce the certified result in the
%  paper (see README, "Reproducibility notes"). Retrain with train_nn.py to
%  obtain the paper's 10/15/15/1 network.

clc; clear; close all;

thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
addpath(thisDir);
dataDir  = fullfile(repoRoot, 'data');

%% 1. Plant and LQR expert -------------------------------------------------
A = [-5  1;
      3 -5];
B = [0.5;
     1];
C = eye(2);

Q = eye(2);  R = 1;                    % LQR weights (paper: Q = I, R = 1)
Klqr = -lqr(A, B, Q, R);               % control law u = Klqr * x
fprintf('LQR gain  K = [% .4f % .4f]\n', Klqr(1), Klqr(2));

%% 2. Imitation-learning data ---------------------------------------------
% Non-negative state samples at several magnitudes, shuffled; u = K z.
scales = [0.01, 0.1, 1, 10];
nPer   = 500;
Z = [];
for s = scales
    Z = [Z; rand(nPer, size(A,1)) * s]; %#ok<AGROW>
end
Z = Z(randperm(size(Z,1)), :);          % shuffle rows
U = (Klqr * Z')';                       % targets (N x 1)

outStates = fullfile(dataDir, 'training', 'lqr_states.csv');
outInputs = fullfile(dataDir, 'training', 'lqr_inputs.csv');
writematrix(Z, outStates);
writematrix(U, outInputs);
fprintf('Wrote %d training samples to data/training/.\n', size(Z,1));

%% 3-4. Load trained weights and compute the sector bound -----------------
% Point this at your exported network. Shipped options:
%   net_10_10_10_1  (the paper's worked example; reproduces its certificate)
%   net_10_10_1     (shallower snapshot; does not certify on this plant)
%   net_10_20_1     (empirically stabilizing; bound too loose to certify)
netDir = fullfile(dataDir, 'weights', 'net_10_10_10_1');
W = load_weights(netDir);

fprintf('\nLoaded network from %s\n', netDir);
fprintf('  architecture: %d', size(W{1}, 2));           % input dimension
for i = 1:numel(W), fprintf(' -> %d', size(W{i}, 1)); end
fprintf('   (%d weight matrices)\n', numel(W));

[Gamma1, Gamma2] = sector_bound(W, [0 1]);              % tanh sector [0,1]
fprintf('  sector bound  Gamma2 = [% .4f % .4f]\n', Gamma2(1), Gamma2(2));

%% 5. Stability certificate (Theorem 3) -----------------------------------
[isStable, info] = verify_stability(A, B, C, Gamma1, Gamma2);

fprintf('\nA + B*Gamma1*C (should be Metzler):\n');  disp(info.M1);
fprintf('A + B*Gamma2*C (should be Hurwitz):\n');    disp(info.M2);
fprintf('eig(A + B*Gamma2*C) = [% .4f % .4f]\n', ...
        real(info.eigM2(1)), real(info.eigM2(2)));
fprintf('Metzler(M1) = %d   Hurwitz(M2) = %d\n', ...
        info.isMetzler, info.isHurwitz);

if isStable
    fprintf('==> CERTIFIED globally exponentially stable.\n');
else
    fprintf(['==> NOT certified with these weights. This network does not ' ...
             'satisfy the\n    positive-Aizerman conditions for this plant. ' ...
             'Use net_10_10_10_1 (the\n    paper''s example) or retrain with ' ...
             'train_nn.py.\n']);
end
