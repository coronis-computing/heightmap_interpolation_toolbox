classdef PURBFInterpolant < Interpolant
    %PURBFInterpolant Interpolant using Partition of Unity Radial Basis Functions
    
    properties
        coverCenters;
        coverRadius;
        weightFun; % Compactly-supported RBF used for interpolation weights (Sheppard's blending of individual RBF in the 2D cover)
    end
    
    methods
        function obj = PURBFInterpolant(x, y, z, varargin)

            % Superclass constructor
            obj@Interpolant(x, y, z);
            
            [centers, radius] = PURBFInterpolant.circleCover2D(x, y, 10, 0.75, 10);
            
            figure;
            plot(x, y, '.');
            for i = 1:size(centers, 1)
                plotCircle(centers(i, 1), centers(i, 2), radius(i));
            end
                        
        end
        
        function z = interpolate(obj, x, y)
            z = [];
        end        
    end
    methods (Static)
        function [centers, radius] = circleCover2D(x, y, m, overlap, minSamples)
            % Covers a 2D region with, at most, m x m overlapping circles
            
            % Parameters' check            
            if ~isvector(x) || ~isvector(y)
                error('x and y inputs must be vectors');
            end            
            if numel(x) ~= numel(y)
                error('x and y inputs must have the same number of elements');
            end
            
            % Compute the extends of the data
            minX = min(x); 
            minY = min(y);
            maxX = max(x); 
            maxY = max(y);
            
            % Compute the delta between regularly placed centers of the
            % circles
            delta = (maxX-minX)/m; 
            [cx, cy] = meshgrid(minX+0.5*delta:delta:maxX+0.5*delta, minY-0.5*delta:delta:maxY+0.5*delta);
            centers = [cx(:), cy(:)];
            radius = overlap*delta*ones(numel(cx), 1);
            
            % Check if each individual circle in the cover has at least 
            
        end
    end
end

