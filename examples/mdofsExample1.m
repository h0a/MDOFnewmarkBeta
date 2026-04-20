%% Newmark-beta integration for 3-DOF system
clear; clc; close all;

%% --- 3-DOF example: 3 masses in a chain (grounded at both ends) ---
m1 = 1.0;  m2 = 1.2;  m3 = 0.8;              % masses [kg]
M  = diag([m1 m2 m3]);

% Springs: ground-k1-m1-k2-m2-k3-m3-k4-ground
k1 = 2000; k2 = 1500; k3 = 1800; k4 = 2200;  % [N/m]
K = [ k1+k2   -k2       0;
      -k2    k2+k3    -k3;
       0      -k3    k3+k4 ];

% Dampers: same topology as springs (Rayleigh is also possible, but here physical dashpots)
c1 = 6; c2 = 5; c3 = 5.5; c4 = 6.5;          % [N*s/m]
C = [ c1+c2   -c2       0;
      -c2    c2+c3    -c3;
       0      -c3    c3+c4 ];

%% --- Time settings ---
dt = 1e-3;                 % time step [s]
tEnd = 2.0;                % total time [s]
t = 0:dt:tEnd;
nSteps = numel(t);

%% --- External force vector f(t) (3 x nSteps) ---
% Example: harmonic force on DOF 2 + short pulse on DOF 1
F = zeros(3, nSteps);

F0 = 50;         % amplitude [N]
freq = 8;        % Hz
F(2,:) = F0*sin(2*pi*freq*t);  % harmonic on DOF 2

% half-sine pulse on DOF 1 between 0 and 0.2 s
Tp = 0.2;
idx = t <= Tp;
F(1,idx) = 80*sin(pi*t(idx)/Tp);

%% --- Initial conditions ---
u0 = [0; 0; 0];            % initial displacement
v0 = [0; 0; 0];            % initial velocity

%% --- Newmark parameters (average acceleration, unconditionally stable for linear systems) ---
beta  = 1/4;
gamma = 1/2;

%% --- Integrate using Newmark-beta ---
[u, v, a] = newmarkBetaMDOF(M, C, K, F, dt, u0, v0, beta, gamma);

%% --- Plot results ---
figure('Color','w');
subplot(3,1,1);
plot(t, u(1,:), 'LineWidth', 1.2); hold on;
plot(t, u(2,:), 'LineWidth', 1.2);
plot(t, u(3,:), 'LineWidth', 1.2);
grid on; ylabel('u [m]');
legend('DOF1','DOF2','DOF3'); title('Displacement');

subplot(3,1,2);
plot(t, v(1,:), 'LineWidth', 1.2); hold on;
plot(t, v(2,:), 'LineWidth', 1.2);
plot(t, v(3,:), 'LineWidth', 1.2);
grid on; ylabel('v [m/s]');
title('Velocity');

subplot(3,1,3);
plot(t, a(1,:), 'LineWidth', 1.2); hold on;
plot(t, a(2,:), 'LineWidth', 1.2);
plot(t, a(3,:), 'LineWidth', 1.2);
grid on; ylabel('a [m/s^2]'); xlabel('t [s]');
title('Acceleration');