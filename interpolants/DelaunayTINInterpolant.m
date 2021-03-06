classdef DelaunayTINInterpolant < Interpolant
    %DelaunayInterpolant Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scatInterpObj;
    end
    
    methods
        function obj = DelaunayTINInterpolant(x, y, z)            
            %NEARESTNEIGHBORINTERPOLANT Construct an instance of this class
            %   Detailed explanation goes here
            
            % Superclass constructor
            obj@Interpolant(x, y, z);
            
            obj.scatInterpObj = scatteredInterpolant(x, y, z, 'linear');
        end
        
        function z = interpolate(obj, x, y)
            Interpolant.checkSizes(x, y);
            z = obj.scatInterpObj(x, y);
        end
    end
end

