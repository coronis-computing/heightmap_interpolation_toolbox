function demoVariogramAndKriging(dataId)
%demoVariogramAndKriging Script showing the Variogram fitting and Kriging interpolant.
% Note: same result as in demoInterpolants, just that in this script we
% show the fitted experimental variogram.

    %% Parse parameters
    if nargin < 1 || isempty(dataId)
        dataId = 'seamount';
    end

    %% Get the sample data and options
    [x, y, z, xi, yi, zt, demoOptions] = getSampleDataset(dataId);
    
    %% Create the variogram
    vg = Variogram(x, y, z, 'model', demoOptions.Kriging.Variogram.Type, ...
                            'DistanceType', demoOptions.DistanceType, ...
                            'NumBins', demoOptions.Kriging.Variogram.NumSamples, ...
                            'OptimNugget', demoOptions.Kriging.Variogram.OptimNugget);
    vg.plot();
    title('Experimental Variogram');
    
    %% Use it in the Kriging
    krigInterp = KrigingInterpolant(x, y, z, vg, 'DistanceType', demoOptions.DistanceType, ...
                                                 'PolynomialDegree', demoOptions.Kriging.PolynomialDegree, ...
                                                 'Regularization', demoOptions.Kriging.Regularization);
    ziKrig = krigInterp.interpolate(xi, yi);
    
    %% Prepare the base plot and show the scattered input data
    xLabel = demoOptions.Plot.XLabel;
    yLabel = demoOptions.Plot.YLabel;
    zLabel = demoOptions.Plot.ZLabel;
    axisEqual = demoOptions.Plot.AxisEqual;
    figure;
    plotResult(x, y, z, [], [], [], 1, 2, 1, 'Input Samples', xLabel, yLabel, zLabel, axisEqual);
    
    %% Show the Kriging results
    plotResult(x, y, z, xi, yi, ziKrig, 1, 2, 2, 'Kriging Interpolant', xLabel, yLabel, zLabel, axisEqual);    
end