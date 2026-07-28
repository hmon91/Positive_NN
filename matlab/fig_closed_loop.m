%% FIG_CLOSED_LOOP
%  Figure 4 of the paper: simulate the closed loop
%      xdot = A x + B * pi(C x)
%  from a set of random non-negative initial conditions and plot
%   (a) the control-input trajectory inside the sector cone, and
%   (b) the state trajectories over time.
%
%  Uses ode45 and re-evaluates the controller along each solution (no
%  global variables). Edit NETDIR to select the network.

clc; clear; close all;

thisDir  = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
addpath(thisDir);

%% Plant and network -------------------------------------------------------
A = [-5  1;
      3 -5];
B = [0.5;
     1];
C = eye(2);

netDir = fullfile(repoRoot, 'data', 'weights', 'net_10_20_1');
W      = load_weights(netDir);
[~, Gamma2] = sector_bound(W, [0 1]);

nIC   = 50;                 % number of random initial conditions
tspan = [0 3];
x0max = 100;                % initial conditions drawn from [0, x0max]^n

%% Sector cone surfaces (u = +/- Gamma2 * [x1; x2]) ------------------------
[Xg, Yg] = meshgrid(linspace(0, x0max, 40), linspace(0, x0max, 40));
Zt =  Gamma2(1)*Xg + Gamma2(2)*Yg;
Zb = -Zt;

figA = figure('Name', 'Input in sector cone', 'Color', 'w'); hold on; grid on; box on
surf(Xg, Yg, Zt, 'FaceAlpha', 0.3, 'FaceColor', 'r', 'EdgeColor', 'none');
surf(Xg, Yg, Zb, 'FaceAlpha', 0.3, 'FaceColor', 'b', 'EdgeColor', 'none');

figB = figure('Name', 'State trajectories', 'Color', 'w'); hold on; grid on; box on

%% Simulate ---------------------------------------------------------------
odeFun = @(t, x) A*x + B*nn_forward(W, C*x);
for h = 1:nIC
    x0 = x0max * abs(rand(size(A,1), 1));
    [t, x] = ode45(odeFun, tspan, x0);

    u = nn_forward(W, C*x.');           % control along the trajectory (1 x N)

    figure(figA);
    plot3(x(:,1), x(:,2), u(:), 'k', 'LineWidth', 1.2);

    figure(figB);
    plot(t, x(:,1), 'b', t, x(:,2), 'r', 'LineWidth', 1.2);
end

figure(figA);
set(gca, 'FontSize', 14);
xlabel('x_1', 'FontSize', 18); ylabel('x_2', 'FontSize', 18);
zlabel('control input u', 'FontSize', 18);
legend('\Gamma_2 x', '\Gamma_1 x', 'input trajectories', 'Location', 'best');
view(45, 20);

figure(figB);
set(gca, 'FontSize', 14);
xlabel('time', 'FontSize', 18); ylabel('state variables', 'FontSize', 18);
legend('x_1', 'x_2', 'Location', 'best');
