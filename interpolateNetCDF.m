function interpolateNetCDF(inputNetCDF, outputNetCDF, method, options)
% Function expecting an EMODnet Bathymetry-compliant NetCDF4 file
% Input:
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
% - 'inpainting': Moving Least Squares.

%% Script
img = ncread(inputNetCDF , 'elevation');
mask = ncread(inputNetCDF, 'interpolation_flag');
mask = ~isnan(mask); % Convert to boolean
img(~mask) = 0; % To avoid numerical issues because of NaNs

C = strsplit(method, '.');
methodStart = C{1};
if numel(C) > 1
    methodSub = lower(C{2});
end

if strcmpi(methodStart, 'nearest') || ...
   strcmpi(methodStart, 'delaunay') || ...
   strcmpi(methodStart, 'natural') || ...
   strcmpi(methodStart, 'idw') || ...
   strcmpi(methodStart, 'kriging') || ...
   strcmpi(methodStart, 'mls') || ...
   strcmpi(methodStart, 'rbf') || ...
   strcmpi(methodStart, 'qtpurbf')

    % Scattered data interpolation method
    error('Still not implemented!');
    
elseif strcmpi(methodStart, 'inpainting')
    % Inpainting method
    switch methodSub
        case 'sobolev'
            interp = inpaintSobolev(img, mask);
        case 'tv'
            interp = inpaintTV(img, mask);
        case 'amle'
            interp = inpaintAMLE(img, mask);
        case 'ccst'
            interp = inpaintCCST(img, mask, 0);
        otherwise
            error('Unknown inpainting type');
    end    
else
    error(sprintf('Unknown method %s', method));
end

% Write results
copyfile(inputNetCDF, outputNetCDF);
ncwrite(outputNetCDF, 'elevation', interp);
