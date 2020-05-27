function demoRBFInterpolants(dataId)
%demoRBFInterpolants Simple script showing the different RBF interpolants available in the toolbox.

    %% Parse parameters
    if nargin < 1 || isempty(dataId)
        dataId = 'seamount';
    end

    %% Get the sample data and options
    [x, y, z, xi, yi, zt, demoOptions] = getSampleDataset(dataId);
    
    %% Show the original function evaluated on the grid, if available
    figure;
    xLabel = demoOptions.Plot.XLabel;
    yLabel = demoOptions.Plot.YLabel;
    zLabel = demoOptions.Plot.ZLabel;
    axisEqual = demoOptions.Plot.AxisEqual;
    spNumRows = 3;
    spNumCols = 4;
    if ~isempty(zt)
        plotResult([], [], [], xi, yi, zt, spNumRows, spNumCols, 1, 'Original Function', xLabel, yLabel, zLabel, axisEqual);    
    else
        % Print a text in the subplot location?
    end
    
    %% Prepare show the scattered input data    
    plotResult(x, y, z, [], [], [], spNumRows, spNumCols, 2, 'Input Samples', xLabel, yLabel, zLabel, axisEqual);
 
    %% Apply the RBF interpolant with all the RBF definitions available
%     types = {'linear', 'cubic', 'quintic', 'multiquadric', 'thinplate', 'green', 'tensionspline', 'regularizedspline', 'gaussian', 'wendland'};
    types = {'tensionspline', 'regularizedspline'};
    for i = 1:numel(types)
        fprintf('- Interpolating using the Radial Basis Function Interpolant (%s kernel)...', types{i});
        tic;
        rbfInterp = RBFInterpolant(x, y, z, 'DistanceType', demoOptions.DistanceType, ...
                                            'PolynomialDegree', demoOptions.RBF.(types{i}).PolynomialDegree, ...
                                            'RBF', types{i}, ...
                                            'RBFEpsilon', demoOptions.RBF.(types{i}).RBFEpsilon, ... 
                                            'RBFEpsilonIsNormalized', demoOptions.RBF.(types{i}).RBFEpsilon, ... 
                                            'Smooth', demoOptions.RBF.(types{i}).Smooth, ...
                                            'Regularization', demoOptions.RBF.(types{i}).Regularization);
        ziRBF = rbfInterp.interpolate(xi, yi);
        t = toc;
        fprintf(' done (%f seconds)\n', t);
        plotResult(x, y, z, xi, yi, ziRBF, spNumRows, spNumCols, i+1, [types{i} ' RBF Interpolant'], xLabel, yLabel, zLabel, axisEqual);
    end
end
