function demoQuadTreePURBFInterpolants(dataId)
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
    
    %% Apply the RBF interpolant with all the RBF definitions available
    types = {'linear', 'cubic', 'quintic', 'multiquadric', 'thinplate', 'green', 'tensionspline', 'regularizedspline', 'gaussian', 'wendland'};
%     types = {'linear'};
    spInd = 2;
    for i = 1:numel(types)
        fprintf('- Interpolating using the Radial Basis Function Interpolant (%s kernel)...', types{i});
        tic;
        rbfInterp = QuadTreePURBFInterpolant(x, y, z, 'MinPointsInCell', demoOptions.PURBF.MinPointsInCell, ...
                                                      'MinCellSizePercent', demoOptions.PURBF.MinCellSizePercent, ...
                                                      'Overlap', demoOptions.PURBF.Overlap, ...
                                                      'Domain', demoOptions.PURBF.Domain, ...
                                                      'DistanceType', demoOptions.DistanceType, ...
                                                      'PolynomialDegree', demoOptions.RBF.(types{i}).PolynomialDegree, ...
                                                      'RBF', types{i}, ...
                                                      'RBFEpsilon', demoOptions.RBF.(types{i}).RBFEpsilon, ... 
                                                      'Regularization', demoOptions.RBF.(types{i}).Regularization);

        if i == 1
            % Show the QuadTree decomposition as the 2nd subplot
            subplot(spNumRows, spNumCols, spInd);
            title('Input Samples + Quad Tree decomposition');
            rbfInterp.plot(false);
            spInd = spInd+1;
        end

        ziRBF = rbfInterp.interpolate(xi, yi);
        t = toc;
        fprintf(' done (%f seconds)\n', t);
        plotResult(x, y, z, xi, yi, ziRBF, spNumRows, spNumCols, spInd, [types{i} ' RBF Interpolant'], xLabel, yLabel, zLabel, axisEqual);
        spInd = spInd+1;
    end
end
