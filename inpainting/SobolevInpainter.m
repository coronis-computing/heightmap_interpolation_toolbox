classdef SobolevInpainter < FDPDEInpainter    
    % Harmonic inpainter (the same result can be obtained with tension == 1
    % in CCSTInpainter)
    
    methods
        function obj = SobolevInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});                        
        end
        
        function f = stepFun(obj, f, mask)
            f = -div(grad(f));
        end        
    end
end