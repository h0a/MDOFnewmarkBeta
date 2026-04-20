clear
close all
clc

% Dynamics responses of a MDOF system using the Newmark-beta method

addpath("src\.")


%% INPUT DATA
% Store all user-defined data in structures for clarity and easier editing.

% Time integration settings
sim.timeStep = 0.05;   % Time increment used for output [s]
sim.tMax     = 10.0;    % Total simulation time [s]
sim.tForce   = 3;     % Duration of the transient load [s]

% Mechanical model properties
model.mass.m1 = 3.0;    % Mass of DOF 1 [kg]
model.mass.m2 = 2.0;    % Mass of DOF 2 [kg]
model.mass.m3 = 1.0;    % Mass of DOF 3 [kg]

model.stiffness.k1 = 100.0;  % Spring stiffness [N/m]
model.stiffness.k2 = 80.0;   % Spring stiffness [N/m]
model.stiffness.k3 = 60.0;   % Spring stiffness [N/m]
model.stiffness.k4 = 40.0;   % Spring stiffness [N/m]
model.stiffness.k5 = 20.0;   % Spring stiffness [N/m]

% Rayleigh damping coefficients
model.damping.alpha = 0.0;   % Mass-proportional damping coefficient
model.damping.beta  = 0.0;   % Stiffness-proportional damping coefficient

% Initial conditions
initial.displacement = [0; 0; 0];   % Initial displacement vector [m]
initial.velocity     = [0; 0; 0];   % Initial velocity vector [m/s]

% External load definition
loadData.amplitude = [100; 0; 0];   % Force amplitude vector [N]



%% ASSEMBLE SYSTEM MATRICES
% Build the mass, stiffness, and damping matrices.

M = diag([model.mass.m1, model.mass.m2, model.mass.m3]);

K = [ model.stiffness.k1 + model.stiffness.k2 + model.stiffness.k3 + model.stiffness.k5,  -model.stiffness.k3,                                   -model.stiffness.k5;
     -model.stiffness.k3,                                                                  model.stiffness.k3 + model.stiffness.k4,               -model.stiffness.k4;
     -model.stiffness.k5,                                                                 -model.stiffness.k4,                                    model.stiffness.k4 + model.stiffness.k5];

C = model.damping.alpha*M + model.damping.beta*K;

nDof = size(M, 1);


%% TIME INTEGRATION

% Newmark parameters (average acceleration, unconditionally stable for linear systems) ---
beta  = 1/4;
gamma = 1/2;

% total simulation time vector
tspan   = 0:sim.timeStep:sim.tMax;

% force vector in time
F = zeros(3, numel(tspan));
t = 0:sim.timeStep:sim.tForce;
freq = 3;        % Hz
F(2,1:numel(t)) = loadData.amplitude(1)*sin(2*pi*freq*t);  % harmonic on DOF 2

% half-sine pulse on DOF 1 between 0 and 0.2 s
% Tp = 0.2;
% idx = t <= Tp;
% F(1,idx) = 80*sin(pi*t(idx)/Tp);

% Integrate using Newmark-beta ---
[u, v, a] = newmarkBetaMDOF(M, C, K, F, sim.timeStep, initial.displacement, initial.velocity, beta, gamma);



%% POST-PROCESSING

z = zeros(numel(tspan),6);
z(:,1:3) = u';
z(:,4:end) = v';

results.t    = tspan;
results.z    = z;
results.u    = u';
results.uDot = v';

results.M    = M;
results.C    = C;
results.K    = K;


plotSettings.fontSize   = 20;
plotSettings.lineWidth  = 3;
plotSettings.fontAngle  = 'normal';
plotSettings.markerSize = 8;
plotSettings.pauseTime  = 0.05;
plotSettings.frameStep  = 5;

% narutal length of springs k1, k3, k4 (for geometry of the plot only)
plotSettings.geometry.L1 = 0.2;
plotSettings.geometry.L2 = 0.2;
plotSettings.geometry.L3 = 0.2;




%% VIDEOs

Plot_bar(results, plotSettings);


%% PLOTs

close all

figure('Color','k','Position',[0 0 1200 600]);
subplot(3,1,1);
plot(tspan, u(1,:), 'LineWidth', 2); hold on;
plot(tspan, u(2,:), 'LineWidth', 2);
plot(tspan, u(3,:), 'LineWidth', 2);
grid on; ylabel('$u$ [m]','Interpreter','latex');
legend('$u_1$','$u_2$','$u_3$','Interpreter','latex','FontSize', 20); 
title('Displacement','Interpreter','latex');
set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex');

subplot(3,1,2);
plot(tspan, v(1,:), 'LineWidth', 2); hold on;
plot(tspan, v(2,:), 'LineWidth', 2);
plot(tspan, v(3,:), 'LineWidth', 2);
grid on; ylabel('$v$ [m/s]','Interpreter','latex');
title('Velocity','Interpreter','latex'); 
set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex');

subplot(3,1,3);
plot(tspan, a(1,:), 'LineWidth', 2); hold on;
plot(tspan, a(2,:), 'LineWidth', 2);
plot(tspan, a(3,:), 'LineWidth', 2);
grid on; ylabel('$a$ [m/s$^2$]','Interpreter','latex'); 
xlabel('$t$ [s]','Interpreter','latex');
title('Acceleration','Interpreter','latex'); 
set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex');