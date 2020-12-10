function [Kbx, Kby] = backwardDifferenceKernels(hx, hy)
% Creates the backward difference kernels
% 
% Input:
%   hx: grid step size in X (defaults to 1 if not set)
%   hy: grid step size in Y (defaults to hx if not set)
% 
% Output:
%   Kbx, Kby: backward difference kernels in x/y
% 

Kbx = zeros(3, 3);
Kbx(2, 2) = 1;
Kbx(2, 1) = -1;
Kbx = Kbx/hx;

Kby = zeros(3, 3);
Kby(2, 2) = 1;
Kby(1, 2) = -1;
Kby = Kby/hy;

end
