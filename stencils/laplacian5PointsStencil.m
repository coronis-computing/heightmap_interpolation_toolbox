function stencil = laplacian5PointsStencil(hx, hy)
% The 5-points Laplacian stencil for arbitrary step sizes in X/Y
% 
% Input:
%   hx: grid step size in X (defaults to 1 if not set)
%   hy: grid step size in Y (defaults to hx if not set)
% 
% Output:
%   stencil: the 3x3 5-points Laplacian stencil
% 

if nargin < 1
    hx = 1;
end
if nargin < 2
    hy = hx;
end

stencil = hx * [ 0 0 0; 1 -2 1; 0 0 0 ] + hy * [ 0 1 0; 0 -2 0; 0 1 0 ];