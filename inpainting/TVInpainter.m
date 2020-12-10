classdef TVInpainter < FDPDEInpainter    
    % Total Variation (TV) inpainter
    
    properties
        epsilon = 1e-2;
    end
    
    methods
        function obj = TVInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});                        
            varargin = obj.removeParentParametersFromVarargin(varargin{:});
            
            p = inputParser;
            validGTZero = @(x) isscalar(x) && x >= 0;
            addParameter(p, 'Epsilon', 1e-2, validGTZero);
            parse(p, varargin{:});
            
            obj.epsilon = p.Results.Epsilon;
        end
        
        function f = stepFun(obj, f, mask)
         	f = -div(obj.neps(grad(f)));
        end        
        
        function u = amplitude(obj, u)
            u = sqrt(sum(u.^2,3)+obj.epsilon^2);
        end
        
        function u = neps(obj, u)
            u = u./repmat(obj.amplitude(u), [1 1 2]);
        end        
    end
end