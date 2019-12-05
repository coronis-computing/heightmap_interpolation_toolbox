function demoInterpolants(dataId)
%demoInterpolants Script showing the different interpolants available in the toolbox.

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
    spNumCols = 3;
    if ~isempty(zt)
        plotResult([], [], [], xi, yi, zt, spNumRows, spNumCols, 1, 'Original Function', xLabel, yLabel, zLabel, axisEqual);    
    else
        % Print a text in the subplot location?
    end
    
    %% Prepare show the scattered input data    
    plotResult(x, y, z, [], [], [], spNumRows, spNumCols, 2, 'Input Samples', xLabel, yLabel, zLabel, axisEqual);
        
    %% Interpolate with each of the methods available
    
    %% Nearest neighbor
    fprintf('- Interpolating using the Nearest Neighbor Interpolant...');
    tic;
    nearNeighInterp = NearestNeighborInterpolant(x, y, z);
    ziNear = nearNeighInterp.interpolate(xi, yi);
    t = toc;
    fprintf(' done (%f seconds)\n', t);
    plotResult(x, y, z, xi, yi, ziNear, spNumRows, spNumCols, 3, 'Nearest Neighbor Interpolant', xLabel, yLabel, zLabel, axisEqual);

    %% Delaunay Triangulation
    fprintf('- Interpolating using the Delaunay Interpolant...');
    tic;    
    dtInterp = DelaunayTINInterpolant(x, y, z);
    ziDT = dtInterp.interpolate(xi, yi);
    t = toc;
    fprintf(' done (%f seconds)\n', t);
    plotResult(x, y, z, xi, yi, ziDT, spNumRows, spNumCols, 4, 'Delaunay (linear) Interpolant', xLabel, yLabel, zLabel, axisEqual);

    %% Natural Neighbors
    fprintf('- Interpolating using the Natural Neighbors Interpolant...');
    tic;
    naturNeighInterp = NaturalNeighborsInterpolant(x, y, z);
    ziNatur = naturNeighInterp.interpolate(xi, yi);
    t = toc;
    fprintf(' done (%f seconds)\n', t);
    plotResult(x, y, z, xi, yi, ziNatur, spNumRows, spNumCols, 5, 'Natural Neighbor Interpolant', xLabel, yLabel, zLabel, axisEqual);

    %% IDW interpolant
    fprintf('- Interpolating using the Inverse-Distance-Weighted Interpolant...');
    tic;
    idwInterp = IDWInterpolant(x, y, z, 'DistanceType', demoOptions.DistanceType, ...
                                        'SearchType', demoOptions.IDW.SearchType, ...
                                        'k', demoOptions.IDW.K, ...
                                        'Radius', demoOptions.IDW.Radius, ...
                                        'Power', demoOptions.IDW.Power);
    ziIDW = idwInterp.interpolate(xi, yi);
    t = toc;
    fprintf(' done (%f seconds)\n', t);
    plotResult(x, y, z, xi, yi, ziIDW, spNumRows, spNumCols, 6, 'Inverse Distance Weighted Interpolant', xLabel, yLabel, zLabel, axisEqual);

    %% RBF interpolant
    fprintf('- Interpolating using the Radial Basis Function Interpolant (%s kernel)...', demoOptions.RBF.RBF);
    tic;
    rbfInterp = RBFInterpolant(x, y, z, 'DistanceType', demoOptions.DistanceType, ...
                                        'PolynomialDegree', demoOptions.RBF.(demoOptions.RBF.RBF).PolynomialDegree, ...
                                        'RBF', demoOptions.RBF.RBF, ...
                                        'RBFEpsilon', demoOptions.RBF.(demoOptions.RBF.RBF).RBFEpsilon, ... 
                                        'Smooth', demoOptions.RBF.(demoOptions.RBF.RBF).Smooth, ...
                                        'Regularization', demoOptions.RBF.(demoOptions.RBF.RBF).Regularization);
    ziRBF = rbfInterp.interpolate(xi, yi);
    t = toc;
    fprintf(' done (%f seconds)\n', t);
    plotResult(x, y, z, xi, yi, ziRBF, spNumRows, spNumCols, 7, ['(' demoOptions.RBF.RBF ') RBF Interpolant'], xLabel, yLabel, zLabel, axisEqual);

    %% Kriging interpolant
    fprintf('- Interpolating using the Kriging Interpolant...');
    tic;
    % Create the experimental variogram from the samples
    vg = Variogram(x, y, z, 'model', demoOptions.Kriging.Variogram.Type, ...
                            'DistanceType', demoOptions.DistanceType, ...
                            'NumBins', demoOptions.Kriging.Variogram.NumSamples, ...
                            'OptimNugget', demoOptions.Kriging.Variogram.OptimNugget);
    
    % Use it in the Kriging
    krigInterp = KrigingInterpolant(x, y, z, vg, 'DistanceType', demoOptions.DistanceType, ...
                                                 'PolynomialDegree', demoOptions.Kriging.PolynomialDegree, ...
                                                 'Smooth', demoOptions.Kriging.Smooth, ...
                                                 'Regularization', demoOptions.Kriging.Regularization);
    ziKrig = krigInterp.interpolate(xi, yi);
    t = toc;
    fprintf(' done (%f seconds)\n', t);
    plotResult(x, y, z, xi, yi, ziKrig, spNumRows, spNumCols, 8, 'Kriging Interpolant', xLabel, yLabel, zLabel, axisEqual);

    %% MLS interpolant
    fprintf('- Interpolating using the Moving Least Squares Interpolant (%s kernel)...', demoOptions.MLS.RBF);
    tic;
    rbfType = 'wendland';
    epsilon = 3; % That is, support in this case
    mlsInterp = MLSInterpolant(x, y, z, 'DistanceType', demoOptions.DistanceType, ...
                                        'PolynomialDegree', demoOptions.MLS.PolynomialDegree, ...
                                        'RBF', demoOptions.MLS.RBF, ...
                                        'RBFEpsilon', demoOptions.MLS.RBFEpsilon, ...
                                        'MinSamples', demoOptions.MLS.MinSamples);
    ziMLS = mlsInterp.interpolate(xi, yi);
    t = toc;
    fprintf(' done (%f seconds)\n', t);
    plotResult(x, y, z, xi, yi, ziMLS, spNumRows, spNumCols, 9, ['(' rbfType ') MLS Interpolant'], xLabel, yLabel, zLabel, axisEqual);
    
end
