function interp = interpolateNetCDF(inputNetCDF, outputNetCDF, method, options)
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
%                   For the last two cases, you need to indicate in <rbf_type>
%                   the type of the Radial Basis Function to use. Available:
%                       - 'linear'
%                       - 'cubic'
%                       - 'quintic'
%                       - 'multiquadric'
%                       - 'thinplate'
%                       - 'green'
%                       - 'tensionspline'
%                       - 'regularizedspline'
%                       - 'gaussian'
%                       - 'wendland'
%               (For more information on each RBF, please check their
%               individual documentation in their corresponding functions on
%               the "rbf" folder of this toolbox)
%               - 'inpainting.<type>': Inpainting method. Available types:
%                   - 'sobolev'
%                   - 'tv'
%                   - 'ccst'
%                   - 'amle'

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

    if nargin < 4 && ~strcmpi(methodStart, 'Nearest') && ~strcmpi(methodStart, 'Delaunay') && ~strcmpi(methodStart, 'Natural')
        options = hmitScatteredDefaultOptions(x, y, z, xi, yi);
    end

    % Scattered data interpolation method
    error('Still not implemented!');
    
elseif strcmpi(methodStart, 'inpainting')
        
    if nargin < 4
        options = hmitInpaintingDefaultOptions(methodSub);
    end
    
    % Compute the grid step from the data and override defaults or user input
%     lats = ncread(inputNetCDF , 'lat');
%     lons = ncread(inputNetCDF , 'lon');
%     hx = abs((lons(end)-lons(1))/numel(lons));
%     hy = abs((lats(end)-lats(1))/numel(lats));
%     options.GridStepX = hx;
%     options.GridStepY = hy;
    
    % Inpainting method
    param = structToVarargin(options);
    switch methodSub
        case 'sobolev'            
            inpainter = SobolevInpainter(param{:});            
        case 'tv'
            inpainter = TVInpainter(param{:});
%             interp = inpaintTV(img, mask, 1);
        case 'amle'
            inpainter = AMLEInpainter(param{:});
%             interp = inpaintAMLE(img, mask);
        case 'ccst'
            inpainter = CCSTInpainter(param{:});
%             interp = inpaintCCST(img, mask, 0);
        case 'bertalmio'
            inpainter = BertalmioInpainter(param{:});
        otherwise
            error('Unknown inpainting type');
    end    
    % Inpaint!
    interp = inpainter.inpaint(img, mask);
else
    error(sprintf('Unknown method %s', method));
end

% Write results
copyfile(inputNetCDF, outputNetCDF);
ncwrite(outputNetCDF, 'elevation', interp);
