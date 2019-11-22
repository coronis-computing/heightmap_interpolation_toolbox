classdef NearestNeighborInterpolant < Interpolant
    %NEARESTNEIGHBORINTERPOLANT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scatInterpObj;
    end
    
    methods
        function obj = NearestNeighborInterpolant(x, y, z)            
            %NEARESTNEIGHBORINTERPOLANT Construct an instance of this class
            %   Detailed explanation goes here
            
            % Superclass constructor
            obj@Interpolant(x, y, z);
            
            obj.scatInterpObj = scatteredInterpolant(x, y, z, 'nearest');
        end
        
        function z = interpolate(obj, x, y)
            Interpolant.checkSizes(x, y);
            z = obj.scatInterpObj(x, y);
        end
    end
end

