% Create the options structure
options.DistanceType = 'haversine'; % Because x/y are in lat/lon! Would work also with Euclidean distance, but this is more correct...        
% --> IDW
options.IDW.Radius = 5;
options.IDW.SearchType = 'radial';
options.IDW.K = 5; % Not used
options.IDW.Power = 2;
% --> RBF (options for each RBF Type, as required by demoRBFInterpolants!)
options.RBF.RBF = 'thinplate';
%   --> Linear
options.RBF.linear.PolynomialDegree = 1;        
options.RBF.linear.RBFEpsilon = 1;
options.RBF.linear.Smooth = 0;
options.RBF.linear.Regularization = 0;
%   --> Cubic
options.RBF.cubic.PolynomialDegree = 1;        
options.RBF.cubic.RBFEpsilon = 1;
options.RBF.cubic.Smooth = 0;
options.RBF.cubic.Regularization = 0;
%   --> Quintic
options.RBF.quintic.PolynomialDegree = 1;        
options.RBF.quintic.RBFEpsilon = 1;
options.RBF.quintic.Smooth = 0;
options.RBF.quintic.Regularization = 0;
%   --> Multiquadric
options.RBF.multiquadric.PolynomialDegree = 1;        
options.RBF.multiquadric.RBFEpsilon = 1;
options.RBF.multiquadric.Smooth = 0;
options.RBF.multiquadric.Regularization = 0;
%   --> Inverse Multiquadric
options.RBF.inversemultiquadric.PolynomialDegree = 1;        
options.RBF.inversemultiquadric.RBFEpsilon = 1;
options.RBF.inversemultiquadric.Smooth = 0;
options.RBF.inversemultiquadric.Regularization = 0;
%   --> Thin Plate Spline
options.RBF.thinplate.PolynomialDegree = 1;        
options.RBF.thinplate.RBFEpsilon = 1;
options.RBF.thinplate.Smooth = 0;
options.RBF.thinplate.Regularization = 0;
%   --> Green
options.RBF.green.PolynomialDegree = 1;        
options.RBF.green.RBFEpsilon = 1;
options.RBF.green.Smooth = 0;
options.RBF.green.Regularization = 0;
%   --> Spline with tension
options.RBF.tensionspline.PolynomialDegree = 1;        
options.RBF.tensionspline.RBFEpsilon = 1;
options.RBF.tensionspline.Smooth = 0;
options.RBF.tensionspline.Regularization = 0;
%   --> Regularized Spline
options.RBF.regularizedspline.PolynomialDegree = 0;        
options.RBF.regularizedspline.RBFEpsilon = 1;
options.RBF.regularizedspline.Smooth = 0;
options.RBF.regularizedspline.Regularization = 0;        
%   --> Gaussian
options.RBF.gaussian.PolynomialDegree = 0;        
options.RBF.gaussian.RBFEpsilon = 0.1;
options.RBF.gaussian.Smooth = 0;
options.RBF.gaussian.Regularization = 1e-15;
%   --> Wendland
options.RBF.wendland.PolynomialDegree = 1;        
options.RBF.wendland.RBFEpsilon = 1;
options.RBF.wendland.Smooth = 0;
options.RBF.wendland.Regularization = 0;
% --> Kriging
options.Kriging.Variogram.Type = 'gaussian';
options.Kriging.Variogram.NumSamples = 100;
options.Kriging.Variogram.OptimNugget = true;
options.Kriging.PolynomialDegree = 0; % i.e., Ordinary Kriging
options.Kriging.Smooth = 0;
options.Kriging.Regularization = 0;
% --> MLS
options.MLS.PolynomialDegree = 2;
options.MLS.RBF = 'wendland';
options.MLS.RBFEpsilon = 1;
options.MLS.MinSamples = 6;
% --> Visualization
options.Plot.XLabel = 'Longitude';
options.Plot.YLabel = 'Latitude';
options.Plot.ZLabel = 'Depth';       
options.Plot.AxisEqual = false;