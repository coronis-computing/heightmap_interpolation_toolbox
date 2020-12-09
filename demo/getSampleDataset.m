function [x, y, z, xi, yi, zt, demoOptions] = getSampleDataset(dataId)
%getSampleDataset Gets sample data to use in the demos given an identifier
%(string)
% 
% This function is not intended to be used by the end-user of the toolbox, is just supposed to be used within the demo scripts!
% 
% INPUT:
%   - dataId: The identifier of the dataset. Available options: 
%              - 'seamount': seamount bathymetric point set (ships with
%                   Matlab, to check availability, try 'load seamount' on the command line)
%              - 'peaks': Matlab 'peaks' function (2 inverted Gaussians)
%              - 'franke': Franke's function (see ./sample_functions/franke.m)
% 
% OUTPUT:
%   - x, y, z: Known samples of the dataset (z = f(x, y)).
%   - xi, yi: Locations to interpolate in the XY plane.
%   - zt: True values of the function at the interpolation location (if available)
%   - demoOptions: The options of the algorithm that we found to be the best
%       for each dataset. It also includes visualization options.

switch lower(dataId)
    case 'seamount'
        % Load sample data
        load seamount; % Loads x, y, z
        % Create the evaluation grid
        [xi, yi] = meshgrid(210.8:0.01:211.8, -48.5:0.01:-47.9);
        % True values of the function at the evaluation grid (unknown in
        % this case)
        zt = []; 
        % Create the options structure
        demoOptions.DistanceType = 'haversine'; % Because x/y are in lat/lon! Would work also with Euclidean distance, but this is more correct...        
        % --> IDW
        demoOptions.IDW.Radius = 5;
        demoOptions.IDW.SearchType = 'radial';
        demoOptions.IDW.K = 5; % Not used
        demoOptions.IDW.Power = 2;
        % --> RBF (options for each RBF Type, as required by demoRBFInterpolants!)
        demoOptions.RBF.RBF = 'thinplate';
        %   --> Linear
        demoOptions.RBF.linear.PolynomialDegree = 1;        
        demoOptions.RBF.linear.RBFEpsilon = 1;
        demoOptions.RBF.linear.Smooth = 0;
        demoOptions.RBF.linear.Regularization = 0;
        %   --> Cubic
        demoOptions.RBF.cubic.PolynomialDegree = 1;        
        demoOptions.RBF.cubic.RBFEpsilon = 1;
        demoOptions.RBF.cubic.Smooth = 0;
        demoOptions.RBF.cubic.Regularization = 0;
        %   --> Quintic
        demoOptions.RBF.quintic.PolynomialDegree = 1;        
        demoOptions.RBF.quintic.RBFEpsilon = 1;
        demoOptions.RBF.quintic.Smooth = 0;
        demoOptions.RBF.quintic.Regularization = 0;
        %   --> Multiquadric
        demoOptions.RBF.multiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.multiquadric.RBFEpsilon = 1;
        demoOptions.RBF.multiquadric.Smooth = 0;
        demoOptions.RBF.multiquadric.Regularization = 0;
        %   --> Inverse Multiquadric
        demoOptions.RBF.inversemultiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.inversemultiquadric.RBFEpsilon = 1;
        demoOptions.RBF.inversemultiquadric.Smooth = 0;
        demoOptions.RBF.inversemultiquadric.Regularization = 0;
        %   --> Thin Plate Spline
        demoOptions.RBF.thinplate.PolynomialDegree = 1;        
        demoOptions.RBF.thinplate.RBFEpsilon = 1;
        demoOptions.RBF.thinplate.Smooth = 0;
        demoOptions.RBF.thinplate.Regularization = 0;
        %   --> Green
        demoOptions.RBF.green.PolynomialDegree = 1;        
        demoOptions.RBF.green.RBFEpsilon = 1;
        demoOptions.RBF.green.Smooth = 0;
        demoOptions.RBF.green.Regularization = 0;
        %   --> Spline with tension
        demoOptions.RBF.tensionspline.PolynomialDegree = 1;        
        demoOptions.RBF.tensionspline.RBFEpsilon = 1;
        demoOptions.RBF.tensionspline.Smooth = 0;
        demoOptions.RBF.tensionspline.Regularization = 0;
        %   --> Regularized Spline
        demoOptions.RBF.regularizedspline.PolynomialDegree = 0;        
        demoOptions.RBF.regularizedspline.RBFEpsilon = 0.01;
        demoOptions.RBF.regularizedspline.Smooth = 0;
        demoOptions.RBF.regularizedspline.Regularization = 0;        
        %   --> Gaussian
        demoOptions.RBF.gaussian.PolynomialDegree = 1;        
        demoOptions.RBF.gaussian.RBFEpsilon = 0.025;
        demoOptions.RBF.gaussian.Smooth = 0;
        demoOptions.RBF.gaussian.Regularization = 0;
        %   --> Wendland
        demoOptions.RBF.wendland.PolynomialDegree = 1;        
        demoOptions.RBF.wendland.RBFEpsilon = 0.025;
        demoOptions.RBF.wendland.Smooth = 0;
        demoOptions.RBF.wendland.Regularization = 0;
        % --> Kriging
        demoOptions.Kriging.Variogram.Type = 'gaussian';
        demoOptions.Kriging.Variogram.NumSamples = 100;
        demoOptions.Kriging.Variogram.OptimNugget = true;
        demoOptions.Kriging.PolynomialDegree = 0; % i.e., Ordinary Kriging
        demoOptions.Kriging.Smooth = 0;
        demoOptions.Kriging.Regularization = 0;
        % --> QuadTreePURBF
        demoOptions.PURBF.Domain = [210.8 -48.5 1 0.6000];
        demoOptions.PURBF.MinPointsInCell = 10;
        demoOptions.PURBF.MinCellSizePercent = 0.1;
        demoOptions.PURBF.Overlap = 0.25;
        % --> MLS
        demoOptions.MLS.PolynomialDegree = 2;
        demoOptions.MLS.RBF = 'wendland';
        demoOptions.MLS.RBFEpsilon = 1;
        demoOptions.MLS.MinSamples = 6;
        % --> Visualization
        demoOptions.Plot.XLabel = 'Longitude';
        demoOptions.Plot.YLabel = 'Latitude';
        demoOptions.Plot.ZLabel = 'Depth';       
        demoOptions.Plot.AxisEqual = false;
    case 'peaks'
        % Create 100 samples of Matlab's 'peaks' function
        numSamples = 1000;
        a = -3;
        b = 3;
        samples = (b-a).*rand(numSamples, 2) + a;
        [x, y, z] = peaks(samples(:, 1), samples(:, 2));
        % Create the evaluation grid
        [xi, yi] = meshgrid(-3:0.1:3, -3:0.1:3);
        % True values of the function at the evaluation grid
        [~, ~, zt] = peaks(xi, yi);
        % Create the options structure
        demoOptions.DistanceType = 'euclidean';
        % --> IDW
        demoOptions.IDW.Radius = 5;
        demoOptions.IDW.SearchType = 'radial';
        demoOptions.IDW.K = 5; % Not used
        demoOptions.IDW.Power = 3;
        % --> RBF (options for each RBF Type, as required by demoRBFInterpolants!)
        demoOptions.RBF.RBF = 'thinplate';
        %   --> Linear
        demoOptions.RBF.linear.PolynomialDegree = 1;        
        demoOptions.RBF.linear.RBFEpsilon = 1;
        demoOptions.RBF.linear.Smooth = 0;
        demoOptions.RBF.linear.Regularization = 0;
        %   --> Cubic
        demoOptions.RBF.cubic.PolynomialDegree = 1;        
        demoOptions.RBF.cubic.RBFEpsilon = 1;
        demoOptions.RBF.cubic.Smooth = 0;
        demoOptions.RBF.cubic.Regularization = 0;
        %   --> Quintic
        demoOptions.RBF.quintic.PolynomialDegree = 1;        
        demoOptions.RBF.quintic.RBFEpsilon = 1;
        demoOptions.RBF.quintic.Smooth = 0;
        demoOptions.RBF.quintic.Regularization = 0;
        %   --> Multiquadric
        demoOptions.RBF.multiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.multiquadric.RBFEpsilon = 1;
        demoOptions.RBF.multiquadric.Smooth = 0;
        demoOptions.RBF.multiquadric.Regularization = 0;
        %   --> Inverse Multiquadric
        demoOptions.RBF.inversemultiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.inversemultiquadric.RBFEpsilon = 1;
        demoOptions.RBF.inversemultiquadric.Smooth = 0;
        demoOptions.RBF.inversemultiquadric.Regularization = 0;
        %   --> Thin Plate Spline
        demoOptions.RBF.thinplate.PolynomialDegree = 1;        
        demoOptions.RBF.thinplate.RBFEpsilon = 1;
        demoOptions.RBF.thinplate.Smooth = 0;
        demoOptions.RBF.thinplate.Regularization = 0;
        %   --> Green
        demoOptions.RBF.green.PolynomialDegree = 1;        
        demoOptions.RBF.green.RBFEpsilon = 1;
        demoOptions.RBF.green.Smooth = 0;
        demoOptions.RBF.green.Regularization = 0;
        %   --> Spline with tension
        demoOptions.RBF.tensionspline.PolynomialDegree = 1;        
        demoOptions.RBF.tensionspline.RBFEpsilon = 1;
        demoOptions.RBF.tensionspline.Smooth = 0;
        demoOptions.RBF.tensionspline.Regularization = 0;
        %   --> Regularized Spline
        demoOptions.RBF.regularizedspline.PolynomialDegree = 0;        
        demoOptions.RBF.regularizedspline.RBFEpsilon = 1;
        demoOptions.RBF.regularizedspline.Smooth = 0;
        demoOptions.RBF.regularizedspline.Regularization = 0;        
        %   --> Gaussian
        demoOptions.RBF.gaussian.PolynomialDegree = 1;        
        demoOptions.RBF.gaussian.RBFEpsilon = 1;
        demoOptions.RBF.gaussian.Smooth = 0;
        demoOptions.RBF.gaussian.Regularization = 0;
        %   --> Wendland
        demoOptions.RBF.wendland.PolynomialDegree = 1;        
        demoOptions.RBF.wendland.RBFEpsilon = 2;
        demoOptions.RBF.wendland.Smooth = 0;
        demoOptions.RBF.wendland.Regularization = 0;
        % --> Kriging
        demoOptions.Kriging.Variogram.Type = 'gaussian';
        demoOptions.Kriging.Variogram.NumSamples = 100;
        demoOptions.Kriging.Variogram.OptimNugget = true;
        demoOptions.Kriging.PolynomialDegree = 0; % i.e., Ordinary Kriging
        demoOptions.Kriging.Smooth = 0;
        demoOptions.Kriging.Regularization = 0;
        % --> QuadTreePURBF
        demoOptions.PURBF.Domain = [-3 -3 6 6];
        demoOptions.PURBF.MinPointsInCell = 100;
        demoOptions.PURBF.MinCellSizePercent = 0.1;
        demoOptions.PURBF.Overlap = 0.25;
        % --> MLS
        demoOptions.MLS.PolynomialDegree = 2;
        demoOptions.MLS.RBF = 'wendland';
        demoOptions.MLS.RBFEpsilon = 3;
        demoOptions.MLS.MinSamples = 6;
        % --> Visualization
        demoOptions.Plot.XLabel = 'x';
        demoOptions.Plot.YLabel = 'y';
        demoOptions.Plot.ZLabel = 'z';       
        demoOptions.Plot.AxisEqual = false;
    case 'franke'
        % Create 1000 samples of Franke's function
        addpath('./sample_functions');        
        samples = rand(1000, 2);
        x = samples(:, 1);
        y = samples(:, 2);
        z = franke(samples(:, 1), samples(:, 2));        
        % Create the evaluation grid
        [xi, yi] = meshgrid(0:0.025:1, 0:0.025:1);
        % True values of the function at the evaluation grid
        zt = franke(xi, yi);   
        % Create the options structure
        demoOptions.DistanceType = 'euclidean';
        % --> IDW
        demoOptions.IDW.Radius = 5;
        demoOptions.IDW.SearchType = 'radial';
        demoOptions.IDW.K = 5; % Not used
        demoOptions.IDW.Power = 2;        
        % --> RBF (options for each RBF Type, as required by demoRBFInterpolants!)
        demoOptions.RBF.RBF = 'thinplate';
        %   --> Linear
        demoOptions.RBF.linear.PolynomialDegree = 1;        
        demoOptions.RBF.linear.RBFEpsilon = 1;
        demoOptions.RBF.linear.Smooth = 0;
        demoOptions.RBF.linear.Regularization = 0;
        %   --> Cubic
        demoOptions.RBF.cubic.PolynomialDegree = 1;        
        demoOptions.RBF.cubic.RBFEpsilon = 1;
        demoOptions.RBF.cubic.Smooth = 0;
        demoOptions.RBF.cubic.Regularization = 0;
        %   --> Quintic
        demoOptions.RBF.quintic.PolynomialDegree = 1;        
        demoOptions.RBF.quintic.RBFEpsilon = 1;
        demoOptions.RBF.quintic.Smooth = 0;
        demoOptions.RBF.quintic.Regularization = 0;
        %   --> Multiquadric
        demoOptions.RBF.multiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.multiquadric.RBFEpsilon = 1;
        demoOptions.RBF.multiquadric.Smooth = 0;
        demoOptions.RBF.multiquadric.Regularization = 0;
        %   --> Inverse Multiquadric
        demoOptions.RBF.inversemultiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.inversemultiquadric.RBFEpsilon = 1;
        demoOptions.RBF.inversemultiquadric.Smooth = 0;
        demoOptions.RBF.inversemultiquadric.Regularization = 0;
        %   --> Thin Plate Spline
        demoOptions.RBF.thinplate.PolynomialDegree = 1;        
        demoOptions.RBF.thinplate.RBFEpsilon = 1;
        demoOptions.RBF.thinplate.Smooth = 0;
        demoOptions.RBF.thinplate.Regularization = 0;
        %   --> Green
        demoOptions.RBF.green.PolynomialDegree = 1;        
        demoOptions.RBF.green.RBFEpsilon = 1;
        demoOptions.RBF.green.Smooth = 0;
        demoOptions.RBF.green.Regularization = 0;
        %   --> Spline with tension
        demoOptions.RBF.tensionspline.PolynomialDegree = 1;        
        demoOptions.RBF.tensionspline.RBFEpsilon = 1;
        demoOptions.RBF.tensionspline.Smooth = 0;
        demoOptions.RBF.tensionspline.Regularization = 0;        
        %   --> Regularized Spline
        demoOptions.RBF.regularizedspline.PolynomialDegree = 0;        
        demoOptions.RBF.regularizedspline.RBFEpsilon = 1;
        demoOptions.RBF.regularizedspline.Smooth = 0;
        demoOptions.RBF.regularizedspline.Regularization = 0;
        %   --> Gaussian
        demoOptions.RBF.gaussian.PolynomialDegree = 1;        
        demoOptions.RBF.gaussian.RBFEpsilon = 0.1;
        demoOptions.RBF.gaussian.Smooth = 0;
        demoOptions.RBF.gaussian.Regularization = 0;
        %   --> Wendland
        demoOptions.RBF.wendland.PolynomialDegree = 1;        
        demoOptions.RBF.wendland.RBFEpsilon = 1;
        demoOptions.RBF.wendland.Smooth = 0;
        demoOptions.RBF.wendland.Regularization = 0;
        % --> Kriging
        demoOptions.Kriging.Variogram.Type = 'gaussian';
        demoOptions.Kriging.Variogram.NumSamples = 100;
        demoOptions.Kriging.Variogram.OptimNugget = true;
        demoOptions.Kriging.PolynomialDegree = 0; % i.e., Ordinary Kriging
        demoOptions.Kriging.Smooth = 0;
        demoOptions.Kriging.Regularization = 0;  
        % --> QuadTreePURBF
        demoOptions.PURBF.Domain = [0 0 1 1];
        demoOptions.PURBF.MinPointsInCell = 25;
        demoOptions.PURBF.MinCellSizePercent = 0.1;
        demoOptions.PURBF.Overlap = 0.25;
        % --> MLS
        demoOptions.MLS.PolynomialDegree = 2;
        demoOptions.MLS.RBF = 'wendland';
        demoOptions.MLS.RBFEpsilon = 1;
        demoOptions.MLS.MinSamples = 6;
        % --> Visualization
        demoOptions.Plot.XLabel = 'x';
        demoOptions.Plot.YLabel = 'y';
        demoOptions.Plot.ZLabel = 'z';       
        demoOptions.Plot.AxisEqual = false;
    case 'flower'
%         % Create 400 samples of Flower function
%         addpath('./sample_functions');        
% %         numSamples = 400;
% %         a = -1;
% %         b = 1;
% %         samples = (b-a).*rand(numSamples, 2) + a;
% %         x = samples(:, 1);
% %         y = samples(:, 2);
% 
%         xx = linspace(-1, 1, 10);
%         yy = linspace(-1, 1, 10);
%         [x, y] = meshgrid(xx, yy);
%         z = flower(x, y);        
%         
%         % Create the evaluation grid
% %         [xi, yi] = meshgrid(-1:1/100:1, -1:1/100:1);
% 
%         xi = xx(randsample(numel(xx), 400, true));
%         yi = yy(randsample(numel(yy), 400, true));
%         % True values of the function at the evaluation grid
%         zt = flower(xi, yi);   

        % Create 1000 samples of Flower function
        addpath('./sample_functions');        
        numSamples = 400;
        a = -1;
        b = 1;
        samples = (b-a).*rand(numSamples, 2) + a;
        x = samples(:, 1);
        y = samples(:, 2);
        z = flower(samples(:, 1), samples(:, 2));        
        
        % Create the evaluation grid
        [xi, yi] = meshgrid(-1:0.025:1, -1:0.025:1);
        % True values of the function at the evaluation grid
        zt = flower(xi, yi);   

        % Create the options structure
        demoOptions.DistanceType = 'euclidean';
        % --> IDW
        demoOptions.IDW.Radius = 5;
        demoOptions.IDW.SearchType = 'radial';
        demoOptions.IDW.K = 5; % Not used
        demoOptions.IDW.Power = 2;        
        % --> RBF (options for each RBF Type, as required by demoRBFInterpolants!)
        demoOptions.RBF.RBF = 'thinplate';
        %   --> Linear
        demoOptions.RBF.linear.PolynomialDegree = 1;        
        demoOptions.RBF.linear.RBFEpsilon = 1;
        demoOptions.RBF.linear.Smooth = 0;
        demoOptions.RBF.linear.Regularization = 0;
        %   --> Cubic
        demoOptions.RBF.cubic.PolynomialDegree = 1;        
        demoOptions.RBF.cubic.RBFEpsilon = 1;
        demoOptions.RBF.cubic.Smooth = 0;
        demoOptions.RBF.cubic.Regularization = 0;
        %   --> Quintic
        demoOptions.RBF.quintic.PolynomialDegree = 1;        
        demoOptions.RBF.quintic.RBFEpsilon = 1;
        demoOptions.RBF.quintic.Smooth = 0;
        demoOptions.RBF.quintic.Regularization = 0;
        %   --> Multiquadric
        demoOptions.RBF.multiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.multiquadric.RBFEpsilon = 1;
        demoOptions.RBF.multiquadric.Smooth = 0;
        demoOptions.RBF.multiquadric.Regularization = 0;
        %   --> Inverse Multiquadric
        demoOptions.RBF.inversemultiquadric.PolynomialDegree = 1;        
        demoOptions.RBF.inversemultiquadric.RBFEpsilon = 1;
        demoOptions.RBF.inversemultiquadric.Smooth = 0;
        demoOptions.RBF.inversemultiquadric.Regularization = 0;
        %   --> Thin Plate Spline
        demoOptions.RBF.thinplate.PolynomialDegree = 1;        
        demoOptions.RBF.thinplate.RBFEpsilon = 1;
        demoOptions.RBF.thinplate.Smooth = 0;
        demoOptions.RBF.thinplate.Regularization = 0;
        %   --> Green
        demoOptions.RBF.green.PolynomialDegree = 1;        
        demoOptions.RBF.green.RBFEpsilon = 1;
        demoOptions.RBF.green.Smooth = 0;
        demoOptions.RBF.green.Regularization = 0;
        %   --> Spline with tension
        demoOptions.RBF.tensionspline.PolynomialDegree = 1;        
        demoOptions.RBF.tensionspline.RBFEpsilon = 1;
        demoOptions.RBF.tensionspline.Smooth = 0;
        demoOptions.RBF.tensionspline.Regularization = 0;        
        %   --> Regularized Spline
        demoOptions.RBF.regularizedspline.PolynomialDegree = 0;        
        demoOptions.RBF.regularizedspline.RBFEpsilon = 1;
        demoOptions.RBF.regularizedspline.Smooth = 0;
        demoOptions.RBF.regularizedspline.Regularization = 0;
        %   --> Gaussian
        demoOptions.RBF.gaussian.PolynomialDegree = 1;        
        demoOptions.RBF.gaussian.RBFEpsilon = 0.01;
        demoOptions.RBF.gaussian.Smooth = 0;
        demoOptions.RBF.gaussian.Regularization = 0;
        %   --> Wendland
        demoOptions.RBF.wendland.PolynomialDegree = 1;        
        demoOptions.RBF.wendland.RBFEpsilon = 1;
        demoOptions.RBF.wendland.Smooth = 0;
        demoOptions.RBF.wendland.Regularization = 0;
        % --> Kriging
        demoOptions.Kriging.Variogram.Type = 'gaussian';
        demoOptions.Kriging.Variogram.NumSamples = 100;
        demoOptions.Kriging.Variogram.OptimNugget = true;
        demoOptions.Kriging.PolynomialDegree = 0; % i.e., Ordinary Kriging
        demoOptions.Kriging.Smooth = 0;
        demoOptions.Kriging.Regularization = 0;  
        % --> QuadTreePURBF
        demoOptions.PURBF.Domain = [-1 -1 2 2];
        demoOptions.PURBF.MinPointsInCell = 25;
        demoOptions.PURBF.MinCellSizePercent = 0.1;
        demoOptions.PURBF.Overlap = 0.25;
        % --> MLS
        demoOptions.MLS.PolynomialDegree = 2;
        demoOptions.MLS.RBF = 'wendland';
        demoOptions.MLS.RBFEpsilon = 1;
        demoOptions.MLS.MinSamples = 6;
        % --> Visualization
        demoOptions.Plot.XLabel = 'x';
        demoOptions.Plot.YLabel = 'y';
        demoOptions.Plot.ZLabel = 'z';       
        demoOptions.Plot.AxisEqual = false;
    otherwise
        error('Unknown sample dataset');
end

end

