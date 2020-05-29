function stencil = biharmonic13PointsStencil(hx, hy)
% The 13-points Biharmonic stencil for arbitrary step sizes in X/Y
% 
% Input:
%   hx: grid step size in X (defaults to 1 if not set)
%   hy: grid step size in Y (defaults to hx if not set)
% 
% Output:
%   stencil: the 5x5 13-points Biharmonic (a.k.a. BiLaplacian) stencil
% 

laplacianStencil = laplacian5PointsStencil(hx, hy);

stencil = conv2(laplacianStencil, laplacianStencil);

end