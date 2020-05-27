function demoRBFInterpolantWithTension(dataId, rbfWithTensionType, tensions)
%demoRBFInterpolants Simple script showing the different RBF interpolants available in the toolbox.

    %% Parse parameters
    if nargin < 1 || isempty(dataId)
        dataId = 'seamount';
    end

    if nargin < 2
%         rbfWithTensionType = 'greenregularizedwithtension';
        rbfWithTensionType = 'greenwithtension';
    end
%     if ~strcmp(rbfWithTensionType, 'tensionspline') && ~strcmp(rbfWithTensionType, 'regularizedspline')
%         error('Only tensionspline and regularizedspline RBF depend on the tension parameter');
%     end    
    
    %% Get the sample data and options
    [x, y, z, xi, yi, zt, demoOptions] = getSampleDataset(dataId);
    
    % Normalize 0..1
%     x = NormalizeValuesInRange(x, min(x(:)), max(x(:)), 0, 1);
%     y = NormalizeValuesInRange(y, min(y(:)), max(y(:)), 0, 1);
%     z = NormalizeValuesInRange(z, min(z(:)), max(z(:)), 0, 1);
%     xi = NormalizeValuesInRange(xi, min(xi(:)), max(xi(:)), 0, 1);
%     yi = NormalizeValuesInRange(yi, min(yi(:)), max(yi(:)), 0, 1);
% 
%     % Convert to a projected coordinate system
%     [x,y]=llutm84(y, x, 0);
%     [xi,yi]=llutm84(yi, xi, 0);

    % The tension parameters to test
    if nargin < 3
%         tensions = [0.1, 1, 10, 100, 1000, 10000];
        tensions = 0.1:0.1:0.9;
    end
    spNumCols = 4;
    spNumRows = ceil((numel(tensions)+2) / spNumCols);
    
    %% Show the original function evaluated on the grid, if available
    figure;
    xLabel = demoOptions.Plot.XLabel;
    yLabel = demoOptions.Plot.YLabel;
    zLabel = demoOptions.Plot.ZLabel;
    axisEqual = demoOptions.Plot.AxisEqual;    
    if ~isempty(zt)
        plotResult([], [], [], xi, yi, zt, spNumRows, spNumCols, 1, 'Original Function', xLabel, yLabel, zLabel, axisEqual);    
    else
        % Print a text in the subplot location?
    end
    
    %% Prepare show the scattered input data    
    plotResult(x, y, z, [], [], [], spNumRows, spNumCols, 2, 'Input Samples', xLabel, yLabel, zLabel, axisEqual);
 
    %% Apply the RBF interpolant with all the RBF definitions available
    i = 3;
    for t = tensions
        % Setup varargin
        args = {'DistanceType' demoOptions.DistanceType};
        if isfield(demoOptions.RBF.(rbfWithTensionType), 'PolynomialDegree') args = [args 'PolynomialDegree', demoOptions.RBF.(rbfWithTensionType).PolynomialDegree]; end
        args = [args, 'RBF', rbfWithTensionType];
        args = [args, 'RBFEpsilon', t];        
        if isfield(demoOptions.RBF.(rbfWithTensionType), 'RBFEpsilonIsNormalized'), args = [args 'RBFEpsilonIsNormalized', demoOptions.RBF.(rbfWithTensionType).RBFEpsilonIsNormalized]; end
        if isfield(demoOptions.RBF.(rbfWithTensionType), 'Regularization'), args = [args 'Regularization' demoOptions.RBF.(rbfWithTensionType).Regularization]; end
        
        % Create and query the interpolant
        fprintf('- Interpolating using the Radial Basis Function Interpolant (%s kernel), with tension = %f...', rbfWithTensionType, t);
        tic;
        rbfInterp = RBFInterpolant(x, y, z, args{:});
        ziRBF = rbfInterp.interpolate(xi, yi);
        time = toc;
        fprintf(' done (%f seconds)\n', time);
        plotResult(x, y, z, xi, yi, ziRBF, spNumRows, spNumCols, i, [rbfWithTensionType ' with tension = ' num2str(t)], xLabel, yLabel, zLabel, axisEqual);
        i = i+1;        
    end
end
