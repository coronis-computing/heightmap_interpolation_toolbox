function imgInpainted = inpaintCCST(img, mask, tension, relTolerance, maxIters)
%INPAINTCCST Inpaint with continous curvature splines in tension

% Input parameters check
if nargin < 4 || isempty(relTolerance)
    relTolerance = 1e-15;
end
if nargin < 5 || isempty(maxIters)
    maxIters = 1e8;
end

% Gradient descent step size
% tau = .8/4;
epsilon = 1e-1;
tau = .9*epsilon/4;

Pi = @(f)f.*(1-mask) + img.*mask;
laplace5pt = [ 0 1 0; 1 -4 1; 0 1 0]; % Laplacian stencil
biharmonic13pt = [0 0 1 0 0; 0 2 -8 2 0; 1 -8 20 -8 1; 0 2 -8 2 0; 0 0 1 0 0]; % Biharmonic stencil

f = img;
for i=1:maxIters
     laplacian = conv2(f, laplace5pt, 'same');
     biharmonic = conv2(f, biharmonic13pt, 'same');
%     g1 = grad(f);
%     g2 = grad(g1);

    myfun = -1*(1-tension).*biharmonic - tension.*laplacian;
    
%     fnew = Pi(f + tau*myfun);
    fnew = Pi(f + tau*myfun);
    
    diff = norm(fnew(:)-f(:))/norm(fnew(:))
    
    % UPDATE
    f = fnew;
    
    % TEST EXIT CONDITION
    if diff<relTolerance
        break
    end
    
    imagesc(f'); axis xy; colorbar;   
end

if i == maxIters
    warning('Maximum number of iterations reached');
end

imgInpainted = f;
