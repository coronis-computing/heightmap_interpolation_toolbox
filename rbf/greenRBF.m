function fx = greenRBF(r)
%% Green's RBF, as defined in :
% David T. Sandwell, Biharmonic spline interpolation of GEOS-3 and SEASAT altimeter data, Geophysical Research Letters, 2, 139-142, 1987.
% 
% Note: this is the same RBF used for interpolation in griddata, when the
%   'v4' method is specified. Using this RBF and no trend
%   ('PolynomialDegree' = -1) will reproduce the same result as griddata
%   function.

fx = (r.^2) .* (log(r)-1);
fx(r==0) = 0; % Fix singularity of Green's function at 0

end

