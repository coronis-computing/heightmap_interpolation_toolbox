function [Kfx, Kfy] = forwardDifferenceKernels(hx, hy)
% Creates the forward difference kernels
% 
% Input:
%   hx: grid step size in X (defaults to 1 if not set)
%   hy: grid step size in Y (defaults to hx if not set)
% 
% Output:
%   Kfx, Kfy: forward difference kernels in x/y
% 

Kfx = zeros(3, 3);
Kfx(2, 2) = -1;
Kfx(2, 3) = 1;
Kfx = Kfx/hx;

Kfy = zeros(3, 3);
Kfy(2, 2) = -1;
Kfy(3, 2) = 1;
Kfy = Kfy/hy;

end

