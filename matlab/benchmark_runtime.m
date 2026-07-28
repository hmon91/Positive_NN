%% BENCHMARK_RUNTIME
%  Times the stability certificate (Theorem 3) for the shipped network.
%  This corresponds to the "computation time" column of Table I: the cost
%  of forming the sector bound and checking the Metzler / Hurwitz
%  conditions is a few microseconds, independent of network depth.
%
%  The IQC baseline it is compared against in the paper (ref. [3]) is NOT
%  redistributed here; see README, "Baseline comparison".

clc; clear; close all;

thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
addpath(thisDir);

A = [-5  1;
      3 -5];
B = [0.5;
     1];
C = eye(2);

netDir = fullfile(repoRoot, 'data', 'weights', 'net_10_20_1');
W      = load_weights(netDir);

nRuns = 1e4;

% Warm up (JIT).
[G1, G2] = sector_bound(W, [0 1]);
verify_stability(A, B, C, G1, G2);

t = zeros(nRuns, 1);
for k = 1:nRuns
    tic;
    [G1, G2] = sector_bound(W, [0 1]);
    verify_stability(A, B, C, G1, G2);
    t(k) = toc;
end

fprintf('Stability test over %d runs:\n', nRuns);
fprintf('  mean   = %.3e s\n', mean(t));
fprintf('  median = %.3e s\n', median(t));
fprintf('  min    = %.3e s\n', min(t));
