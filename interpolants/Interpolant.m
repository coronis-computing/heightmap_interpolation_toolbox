classdef (Abstract) Interpolant
    %INTERPOLANT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data;
    end
    
    methods
        function obj = Interpolant(x, y, z)
            %INTERPOLANT Construct an interpolant
            %   Detailed explanation goes here
            if numel(x) ~= numel(y) || numel(x) ~= numel(z)
                error('x, y and z variables must have the same number of elements');
            end
            
            obj.data = [x y z];
        end        
        
    end
    
    methods (Static)
        function checkSizes(x, y)
            if numel(x) ~= numel(y)
                error('Input x and y query points must have the same number of elements');
            end
        end
    end
    
    methods (Abstract) 
        z = interpolate(obj, x, y)
    end
end

