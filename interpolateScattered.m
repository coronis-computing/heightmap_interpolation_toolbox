function zi = interpolate(x, y, z, xi, yi, method, options)
%INTERPOLATE Convenience function providing a simple interphase to the
%different interpolation methods in the Heightmap Interpolation Toolbox
% 
% Input:
%   - x, y, z: the known function values of the bivariate function f(x,y)=z
%   - xi, yi: locations to interpolate
%   - method: the method to use. Available:
%               - 'Nearest': Nearest Neighbor.
%               - 'Delaunay': Delaunay triangulation (linear interpolation).
%               - 'Natural': Natural neighbors.
%               - 'IDW': Inverse Distance Weighted.
%               - 'Kriging': Kriging interpolation.
%               - 'MLS': Moving Least Squares.
%               - 'RBF.<rbf_type>': Radial Basis Functions.
%               - 'QTPURBF.<rbf_type>': QuadTree Partition of Unity BRF.
%       For the last two cases, you need to indicate in <rbf_type>
%       the type of the Radial Basis Function to use. Available:
%               - 'linear'
%               - 'cubic'
%               - 'quintic'
%               - 'multiquadric'
%               - 'thinplate'
%               - 'green'
%               - 'tensionspline'
%               - 'regularizedspline'
%               - 'gaussian'
%               - 'wendland'
%       For more information on each RBF, please check their
%       individual documentation in their corresponding functions on
%       the "rbf" folder of this toolbox.
%   - options: Options data structure. Each algorithm has its own set of
%       options that may be tunned according to the data. In case this
%       structure is not provided, a set of default values will be
%       generated using the hmitDefaultOptions function. The values
%       returned by this function may not fit your data at all. We
%       encourage the user to read the documentation of the individual
%       methods in order to set the options properly. The parameters
%       structure should follow that returned by the hmitDefaultOptions
%       function, so a good way of setting parameters is to generate this
%       structure using the hmitDefaultOptions function, and then change
%       some of them as required. Note: 'Nearest', 'Delaunay' and 'Natural'
%       methods do not require any parameters, so you can skip this parameter.
% 
% Output:
%   - zi: the interpolated z values
% 

% Parameters' check
if nargin < 7 && ~strcmpi(method, 'Nearest') && ~strcmpi(method, 'Delaunay') && ~strcmpi(method, 'Natural')
    options = hmitDefaultOptions(x, y, z, xi, yi);
end

C = strsplit(method, '.');
method = C{1};
if numel(C) > 1
    rbfType = lower(C{2});
end

switch lower(method)
    case 'nearest'
        nearNeighInterp = NearestNeighborInterpolant(x, y, z);
        zi = nearNeighInterp.interpolate(xi, yi);
    case 'delaunay'
        dtInterp = DelaunayTINInterpolant(x, y, z);
        zi = dtInterp.interpolate(xi, yi);
    case 'natural'
        naturNeighInterp = NaturalNeighborsInterpolant(x, y, z);
        zi = naturNeighInterp.interpolate(xi, yi);
    case 'idw'
        idwInterp = IDWInterpolant(x, y, z, 'DistanceType', options.DistanceType, ...
                                        'SearchType', options.IDW.SearchType, ...
                                        'k', options.IDW.K, ...
                                        'Radius', options.IDW.Radius, ...
                                        'Power', options.IDW.Power);
        zi = idwInterp.interpolate(xi, yi);                            
    case 'kriging'
        % Create the experimental variogram from the samples
        vg = Variogram(x, y, z, 'model', options.Kriging.Variogram.Type, ...
                                'DistanceType', options.DistanceType, ...
                                'NumBins', options.Kriging.Variogram.NumSamples, ...
                                'OptimNugget', options.Kriging.Variogram.OptimNugget);

        % Use it in the Kriging
        krigInterp = KrigingInterpolant(x, y, z, vg, 'DistanceType', options.DistanceType, ...
                                                     'PolynomialDegree', options.Kriging.PolynomialDegree, ...
                                                     'Smooth', options.Kriging.Smooth, ...
                                                     'Regularization', options.Kriging.Regularization);
        zi = krigInterp.interpolate(xi, yi);
    case 'mls'
        mlsInterp = MLSInterpolant(x, y, z, 'DistanceType', options.DistanceType, ...
                                            'PolynomialDegree', options.MLS.PolynomialDegree, ...
                                            'RBF', options.MLS.RBF, ...
                                            'RBFEpsilon', options.MLS.RBFEpsilon, ...
                                            'MinSamples', options.MLS.MinSamples);
        zi = mlsInterp.interpolate(xi, yi);
    case 'rbf'
        rbfInterp = RBFInterpolant(x, y, z, 'DistanceType', options.DistanceType, ...
                                            'PolynomialDegree', options.RBF.(rbfType).PolynomialDegree, ...
                                            'RBF', rbfType, ...
                                            'RBFEpsilon', options.RBF.(rbfType).RBFEpsilon, ... 
                                            'Smooth', options.RBF.(rbfType).Smooth, ...
                                            'Regularization', options.RBF.(rbfType).Regularization);
        zi = rbfInterp.interpolate(xi, yi);          
    case 'qtpurbf'
        rbfInterp = QuadTreePURBFInterpolant(x, y, z, 'MinPointsInCell', options.PURBF.MinPointsInCell, ...
                                                      'Overlap', options.PURBF.Overlap, ...
                                                      'Domain', options.PURBF.Domain, ...
                                                      'DistanceType', options.DistanceType, ...
                                                      'PolynomialDegree', options.RBF.(rbfType).PolynomialDegree, ...
                                                      'RBF', rbfType, ...
                                                      'RBFEpsilon', options.RBF.(rbfType).RBFEpsilon, ... 
                                                      'Smooth', options.RBF.(rbfType).Smooth, ...
                                                      'Regularization', options.RBF.(rbfType).Regularization);
        zi = rbfInterp.interpolate(xi, yi);          
    otherwise
        error('Unknown interpolation method');
end

end
