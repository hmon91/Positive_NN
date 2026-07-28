%% FIG_ACTIVATION_SECTORS
%  Figure 2 of the paper: the ReLU and tanh activation functions, each
%  bounded within the sector [0, 1] (delimited by y = 0 and y = x).

clc; clear; close all;

x  = -3:0.01:3;
lo = zeros(size(x));   % lower sector edge y = 0
hi = x;                % upper sector edge y = x

figure('Name', 'Activation sectors', 'Color', 'w');

% --- ReLU --------------------------------------------------------------
subplot(1, 2, 1); hold on; grid on; box on
fill([x fliplr(x)], [max(hi,lo) fliplr(min(hi,lo))], [0.85 0.85 0.85], ...
     'EdgeColor', 'none', 'FaceAlpha', 0.6);   % sector cone
plot(x, max(x, 0), 'b',  'LineWidth', 3);      % ReLU
plot(x, hi, 'r--', 'LineWidth', 2);            % y = x
plot(x, lo, 'r--', 'LineWidth', 2);            % y = 0
axis([-3 3 -3 3]); axis square
set(gca, 'FontSize', 14);
xlabel('x', 'FontSize', 18); ylabel('f(x)', 'FontSize', 18);
title('ReLU', 'FontSize', 18);

% --- tanh --------------------------------------------------------------
subplot(1, 2, 2); hold on; grid on; box on
fill([x fliplr(x)], [max(hi,lo) fliplr(min(hi,lo))], [0.85 0.85 0.85], ...
     'EdgeColor', 'none', 'FaceAlpha', 0.6);
plot(x, tanh(x), 'b',  'LineWidth', 3);        % tanh
plot(x, hi, 'r--', 'LineWidth', 2);
plot(x, lo, 'r--', 'LineWidth', 2);
axis([-3 3 -3 3]); axis square
set(gca, 'FontSize', 14);
xlabel('x', 'FontSize', 18); ylabel('f(x)', 'FontSize', 18);
title('tanh', 'FontSize', 18);
