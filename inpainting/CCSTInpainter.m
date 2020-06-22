classdef CCSTInpainter < FDPDEInpainter    
    % Continous Curvature Splines in Tension (CCST) inpainter
    % Implements the method in:
    %   Smith, W. H. F, and P. Wessel, 1990, Gridding with continuous curvature splines in tension, Geophysics, 55, 293-305.
    % Should mimic GMT surface (http://gmt.soest.hawaii.edu/doc/latest/surface.html)
    
    properties
        tension = 1e-2; % Tension parameter. Set it to 1 for harmonic interpolation and to 0 for biharmonic interpolation. Any value in between is a mix of both.
        laplacianStencil = [];
    end
    
    methods
        function obj = CCSTInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});                        
            varargin = obj.removeParentParametersFromVarargin(varargin{:});
            
            p = inputParser;
            validTension = @(x) isscalar(x) && x >= 0 && x <=1;
            addParameter(p, 'Tension', 0, validTension);            
            parse(p, varargin{:});
            
            obj.tension = p.Results.Tension;
            
            % Compute the stencils
            obj.laplacianStencil = laplacian5PointsStencil(obj.hx, obj.hy);
        end
        
        function f = stepFun(obj, f, mask)
            laplacian = conv2(f, obj.laplacianStencil, 'same');
            biharmonic = conv2(laplacian, obj.laplacianStencil, 'same');
            
            f = (1-obj.tension).*biharmonic - obj.tension.*laplacian;
        end                
    end
end
