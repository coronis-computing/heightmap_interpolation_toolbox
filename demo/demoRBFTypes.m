function demoRBFTypes(xLimits, yLimits, stepX, stepY, epsilon)
%demoRBFTypes Shows the shape of the various RBF types available in the toolbox

if nargin < 1
    xLimits = [-1 1];
end
if nargin < 2
    yLimits = [-1 1];
end
if nargin < 3
    stepX = 0.1;
end
if nargin < 4
    stepY = 0.1;
end
if nargin < 5
    epsilon = 1;
end

fprintf('- Plotting all available RBFs in the toolbox.\n');
fprintf('  - Options:\n');
fprintf('    - Sampling X at: [%f:%f:%f]\n', xLimits(1), stepX, xLimits(2));
fprintf('    - Sampling Y at: [%f:%f:%f]\n', yLimits(1), stepY, yLimits(2));
fprintf('    - Epsilon (a.k.a. shape parameter) = %f\n', epsilon);

% Create the evaluation grid
[xi, yi] = meshgrid(xLimits(1):stepX:xLimits(2), yLimits(1):stepY:yLimits(2));
cx = xLimits(1) + ((xLimits(2)-xLimits(1))/2);
cy = yLimits(1) + ((yLimits(2)-yLimits(1))/2);

% Compute the evaluation of each RBF
types = {'linear', 'cubic', 'quintic', 'multiquadric', 'thinplate', 'green', 'tensionspline', 'regularizedspline', 'gaussian', 'wendland'};
% types = {'regularizedspline'};
figure;
for i = 1:numel(types)
    rbfFun = rbfTypeToFunctor(types{i}, epsilon);
    dists = pdist2([cx cy], [xi(:), yi(:)]);
    dists = reshape(dists, size(xi));
    ziRBF = rbfFun(dists);
	plotResult([], [], [], xi, yi, ziRBF, 3, 4, i, [types{i} ' RBF'], 'x', 'y', 'z', false);
end
