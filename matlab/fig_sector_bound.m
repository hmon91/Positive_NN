%% FIG_SECTOR_BOUND
%  Figure 3 of the paper: for a set of random non-negative inputs z, plot
%  the network output pi(z) together with the sector bounds Gamma1*z and
%  Gamma2*z (Theorem 2). For SISO networks (scalar output) this reproduces
%  the paper's figure directly; for MIMO networks the first output channel
%  is shown.
%
%  The dashed grey lines show the product-of-2-norms (Lipschitz-type) bound
%  from the literature (ref. [24]) as a conservatism reference.
%
%  Works for a network of any depth. Edit NETDIR to select the network.

clc; clear; close all;

thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
addpath(thisDir);

netDir = fullfile(repoRoot, 'data', 'weights', 'net_10_20_1');
W      = load_weights(netDir);

[Gamma1, Gamma2] = sector_bound(W, [0 1]);          % tanh sector [0,1]

% product of spectral norms (scalar Lipschitz-type upper bound, ref [24])
Lip = 1; for i = 1:numel(W), Lip = Lip * norm(W{i}); end

m   = 100;                                          % number of samples
p   = size(W{1}, 2);                                % input dimension
piZ = zeros(1, m); ub = zeros(1, m); lb = zeros(1, m); lip = zeros(1, m);
for k = 1:m
    z      = abs(rand(p, 1));
    u      = nn_forward(W, z);
    piZ(k) = u(1);
    g2     = Gamma2 * z;   ub(k)  =  g2(1);
    g1     = Gamma1 * z;   lb(k)  =  g1(1);
    lip(k) = Lip * norm(z);                         % |pi(z)| <= Lip*||z||
end

figure('Name', 'Sector bound vs NN output', 'Color', 'w'); hold on; grid on; box on
fill([1:m, m:-1:1], [ub, fliplr(lb)], [0.85 0.85 0.85], ...
     'EdgeColor', 'none', 'FaceAlpha', 0.6, 'DisplayName', 'sector [\Gamma_1,\Gamma_2]');
plot(1:m,  lip, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, ...
     'DisplayName', 'product-of-norms bound [24]');
plot(1:m, -lip, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, ...
     'HandleVisibility', 'off');
plot(1:m, ub, 'r', 'LineWidth', 2, 'DisplayName', '\Gamma_2 z');
plot(1:m, lb, 'b', 'LineWidth', 2, 'DisplayName', '\Gamma_1 z');
plot(1:m, piZ, 'k', 'LineWidth', 2, 'DisplayName', '\pi(z)');
set(gca, 'FontSize', 14);
xlabel('random non-negative input', 'FontSize', 18);
ylabel('output', 'FontSize', 18);
legend('Location', 'best', 'FontSize', 12);
