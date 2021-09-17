function inpainted = inpaintRaster(img, mask, method, options)
%INPAINTRASTER Inpaint a raster image file at the sites specified by a mask

% Get the default set of options if the user did not specify any
if nargin < 4
    options = hmitInpaintingDefaultOptions(method);
end

% Select the inpainting method
param = structToVarargin(options);
switch method
    case 'sobolev'            
        inpainter = SobolevInpainter(param{:});            
    case 'tv'
        inpainter = TVInpainter(param{:});
    case 'amle'
        inpainter = AMLEInpainter(param{:});
    case 'ccst'
        inpainter = CCSTInpainter(param{:});
    case 'bertalmio'
        inpainter = BertalmioInpainter(param{:});
    otherwise
        error('Unknown inpainting type');
end

% Inpaint!
inpainted = inpainter.inpaint(img, mask);

end

