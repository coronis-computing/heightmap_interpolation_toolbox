classdef SobolevInpainter < FDPDEInpainter    
    % Harmonic inpainter (the same result can be obtained with tension == 1
    % in CCSTInpainter)
    
    methods
        function obj = SobolevInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});                        
        end
        
        function f = stepFun(obj, f, mask)
            % Using central differences does not work!
%             options.order = 2;
%             f = div(grad(f, options), options);     
            f = div(grad(f));
        end        
    end
end