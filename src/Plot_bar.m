function Plot_bar(results, plotSettings)
%PLOT_BAR Animate and plot the response of a 3-DOF vertical system.
% -------------------------------------------------------------------------
% Author:
%   Dr. Bruno Roccia
%   Geophysical Institute, University of Bergen
%
% Description:
%   This function creates:
%     1) a schematic animation of a 3-DOF spring-mass system, and
%     2) the time history of the displacement of the third DOF.
%
% Inputs:
%   results      - Structure containing simulation results
%   plotSettings - Structure containing font, geometry, and animation data
% -------------------------------------------------------------------------

% Extract results
t = results.t;
z = results.z;

% Extract plotting settings
myFontSize  = plotSettings.fontSize;

myFontAngle = plotSettings.fontAngle;
sizeMarker  = plotSettings.markerSize;
pauseTime   = plotSettings.pauseTime;
frameStep   = plotSettings.frameStep;

% Geometric dimensions of the schematic model
L1 = plotSettings.geometry.L1;
L2 = plotSettings.geometry.L2;
L3 = plotSettings.geometry.L3;

% Coordinates for the mass blocks (simple rectangles)
box1x = [-0.02  0.02  0.02 -0.02 -0.02];
box1y = [-0.01 -0.01  0.01  0.01 -0.01] * 1.5;

box2x = [-0.015 -0.005 -0.005 -0.015 -0.015];
box2y = [-0.01  -0.01   0.01   0.01  -0.01] * 1.5;

box3x = [-0.02  0.02  0.02 -0.02 -0.02];
box3y = [-0.01 -0.01  0.01  0.01 -0.01] * 1.5;

% Horizontal locations of springs/connectors
spring1x = [-0.01 -0.01];
spring2x = [ 0.01  0.01];
spring3x = [-0.01 -0.01];
spring4x = [-0.01 -0.01];
spring5x = [ 0.01  0.01];

% Initial coordinates based on the first time step
[box1yNow, box2yNow, box3yNow, spring1y, spring2y, spring3y, spring4y, spring5y] = ...
    localComputeGeometry(z(1, :), box1y, box2y, box3y, L1, L2, L3);

figure('Color','k', ...
    'Units','pixels', ...
    'Position',[100 100 1920 1080], ...
    'Resize','off');

% --- Create video writer ---
v = VideoWriter('animation.mp4','MPEG-4');
% v.FrameRate = 1/pauseTime;   % match your animation speed
v.FrameRate = 30;     % fixed, smooth playback
v.Quality   = 100;
open(v);



%% Left panel: mechanical animation
subplot(1,2,1)
hold on

H1  = plot(box1x, box1yNow,    'Color',[0.266,0.674,0.188], 'LineWidth', 2);
H2  = plot(spring1x, spring1y, 'Color',[0,0.447,0.741], 'LineWidth', 2);
H3  = plot(spring2x, spring2y, 'Color',[0,0.447,0.741], 'LineWidth', 2);
H4  = plot(box2x, box2yNow,    'Color',[0.266,0.674,0.188], 'LineWidth', 2);
H5  = plot(spring3x, spring3y, 'Color',[0,0.447,0.741], 'LineWidth', 2);
H6  = plot(box3x, box3yNow,    'Color',[0.266,0.674,0.188], 'LineWidth', 2);
H7  = plot(spring4x, spring4y, 'Color',[0,0.447,0.741], 'LineWidth', 2);
H8  = plot(spring5x, spring5y, 'Color',[0,0.447,0.741], 'LineWidth', 2);

H9  = plot(-0.01, spring1y(2), 'o', 'MarkerSize', sizeMarker, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
H10 = plot( 0.01, spring2y(2), 'o', 'MarkerSize', sizeMarker, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
H11 = plot(-0.01, spring3y(2), 'o', 'MarkerSize', sizeMarker, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
H12 = plot(-0.01, spring4y(2), 'o', 'MarkerSize', sizeMarker, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
H13 = plot( 0.01, spring5y(2), 'o', 'MarkerSize', sizeMarker, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
H14 = plot( 0.00, spring5y(2), 'o', 'MarkerSize', 10,         'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1);

plot(-0.01, 0, 'o', 'MarkerSize', sizeMarker, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
plot( 0.01, 0, 'o', 'MarkerSize', sizeMarker, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'LineWidth', 1);
plot(xlim, [0 0], 'w');

axis([-0.035 0.035 -max(abs(z(:,1)))-7.5*L1 0.5])
set(gca, 'FontSize', myFontSize, 'FontAngle', myFontAngle,'TickLabelInterpreter','latex');
xlabel('Horizontal coordinate [m]','Interpreter','latex');
ylabel('Vertical coordinate [m]','Interpreter','latex');
box on
hold off

%% Right panel: displacement history of DOF 3
subplot(1,2,2)
hold on
plot(t(1), z(1,3), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'LineWidth', 1);
G0 = plot(t(1), z(1,3), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1);
G1 = plot(t(1), z(1,3), 'LineWidth', 2);
axis([0 max(t) -max(abs(z(:,3))) max(abs(z(:,3)))])
box on
grid on
set(gca, 'FontSize', myFontSize, 'FontAngle', myFontAngle,'TickLabelInterpreter','latex');
xlabel('Time [s]','Interpreter','latex');
ylabel('Displacement $u_3$ [m]','Interpreter','latex');

%% Animation loop

for i = 1:frameStep:size(z,1)
    [box1yNow, box2yNow, box3yNow, spring1y, spring2y, spring3y, spring4y, spring5y] = ...
        localComputeGeometry(z(i, :), box1y, box2y, box3y, L1, L2, L3);

    set(H1,  'YData', box1yNow);
    set(H2,  'YData', spring1y);
    set(H3,  'YData', spring2y);
    set(H4,  'YData', box2yNow);
    set(H5,  'YData', spring3y);
    set(H6,  'YData', box3yNow);
    set(H7,  'YData', spring4y);
    set(H8,  'YData', spring5y);
    set(H9,  'YData', spring1y(2));
    set(H10, 'YData', spring2y(2));
    set(H11, 'YData', spring3y(2));
    set(H12, 'YData', spring4y(2));
    set(H13, 'YData', spring5y(2));
    set(H14, 'YData', spring5y(2));

    set(G1, 'XData', t(1:i), 'YData', z(1:i,3));
    set(G0, 'XData', t(i),   'YData', z(i,3));

    % pause(pauseTime)

    drawnow   % IMPORTANT for correct frame capture

    % --- Capture frame ---
    frame = getframe(gcf);
    writeVideo(v, frame);
end

% --- Close video ---
close(v);


end





%%

function [box1yNow, box2yNow, box3yNow, spring1y, spring2y, spring3y, spring4y, spring5y] = ...
    localComputeGeometry(zRow, box1y, box2y, box3y, L1, L2, L3)
%LOCALCOMPUTEGEOMETRY Compute the instantaneous coordinates for animation.

u1 = zRow(1);
u2 = zRow(2);
u3 = zRow(3);

box1yNow = -L1 + box1y - u1;
box2yNow = -L1 - L2 + box2y - u1 - u2;
box3yNow = -L1 - L2 - L3 + box3y - u1 - u2 - u3;

spring1y = [0,            -L1 - u1];
spring2y = [0,            -L1 - u1];
spring3y = [-L1 - u1,     -L1 - L2 - u1 - u2];
spring4y = [-L1 - L2 - u1 - u2,  -L1 - L2 - L3 - u1 - u2 - u3];
spring5y = [-L1 - u1,     -L1 - L2 - L3 - u1 - u2 - u3];

end
