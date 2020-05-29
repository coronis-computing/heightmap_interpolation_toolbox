classdef SobolevInpainter < FDPDEInpainter    
    methods
        function obj = SobolevInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});                        
        end
        
        function f = stepFun(obj, f, mask)
            f = -div(grad(f));
        end        
    end
end