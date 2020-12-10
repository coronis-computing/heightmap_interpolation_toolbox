function [Kcx, Kcy] = centeredDifferenceKernels(hx, hy)
% Creates the centered difference kernels
% 
% Input:
%   hx: grid step size in X (defaults to 1 if not set)
%   hy: grid step size in Y (defaults to hx if not set)
% 
% Output:
%   Kcx, Kcy: centered differences kernels in x/y
% 

Kcx = zeros(3, 3);
Kcx(2, 3) = 0.5;
Kcx(2, 1) = -0.5;
Kcx = Kcx/hx;

Kcy = zeros(3, 3);
Kcy(1, 2) = -0.5;
Kcy(3, 2) = 0.5;
Kcy = Kcy/hy;

end