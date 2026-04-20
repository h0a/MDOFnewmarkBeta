function [u, v, a] = newmarkBetaMDOF(M, C, K, F, dt, u0, v0, beta, gamma)
%NEWARKBETAMDOF  Newmark-beta time integration for linear MDOF systems.
%
% Solves: M*a + C*v + K*u = F(t)
%
% Inputs:
%   M,C,K : (ndof x ndof) matrices
%   F     : (ndof x nSteps) force history
%   dt    : time step
%   u0,v0 : initial displacement/velocity (ndof x 1)
%   beta,gamma : Newmark parameters (e.g. beta=1/4,gamma=1/2)
%
% Outputs:
%   u,v,a : (ndof x nSteps) displacement/velocity/acceleration histories

ndof   = size(M,1);
nSteps = size(F,2);

u = zeros(ndof, nSteps);
v = zeros(ndof, nSteps);
a = zeros(ndof, nSteps);

% initial conditions
u(:,1) = u0(:);
v(:,1) = v0(:);

% initial acceleration from equilibrium at t=0:
% M*a0 = F0 - C*v0 - K*u0
a(:,1) = M \ (F(:,1) - C*v(:,1) - K*u(:,1));

% Newmark constants
a0 = 1/(beta*dt^2);
a1 = gamma/(beta*dt);
a2 = 1/(beta*dt);
a3 = 1/(2*beta) - 1;
a4 = gamma/beta - 1;
a5 = dt*(gamma/(2*beta) - 1);

% Effective stiffness matrix (constant for linear system, constant dt)
Keff = K + a0*M + a1*C;

% Factorize once for efficiency (use LU; stable for general matrices)
[L,U,P] = lu(Keff);

for i = 1:nSteps-1
    % Predict (a.k.a. "effective") load vector at t_{n+1}
    % F_eff = F_{n+1} + M*(a0*u_n + a2*v_n + a3*a_n) + C*(a1*u_n + a4*v_n + a5*a_n)
    Feff = F(:,i+1) ...
        + M*(a0*u(:,i) + a2*v(:,i) + a3*a(:,i)) ...
        + C*(a1*u(:,i) + a4*v(:,i) + a5*a(:,i));

    % Solve for displacement at next step
    u(:,i+1) = U \ (L \ (P*Feff));

    % Update acceleration and velocity using Newmark relations
    a(:,i+1) = a0*(u(:,i+1) - u(:,i)) - a2*v(:,i) - a3*a(:,i);
    v(:,i+1) = v(:,i) + dt*((1-gamma)*a(:,i) + gamma*a(:,i+1));
end

end