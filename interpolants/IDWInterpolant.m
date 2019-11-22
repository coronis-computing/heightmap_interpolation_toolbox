classdef IDWInterpolant < Interpolant
    %DelaunayInterpolant Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        searchObj;        
        power;
    end
    
    methods
        function obj = IDWInterpolant(x, y, z, varargin)            
            %IDWInterpolant Construct an instance of this class
            %   Detailed explanation goes here
            
            % Superclass constructor
            obj@Interpolant(x, y, z);
            
            % Validation functions for the input parameters
            validGreaterThanZero = @(x) isscalar(x) && x > 0;
            validSearchType = @(x) ischar(x) && strcmpi(x, 'radial') || strcmpi(x, 'knn');
            validDistanceType = @(x) ischar(x) && strcmpi(x, 'euclidean') || strcmpi(x, 'haversine');
            
            % Check the input parameters using inputParser
            p = inputParser;
            addParameter(p, 'Radius', 5, validGreaterThanZero);    
            addParameter(p, 'SearchType', 'radial', validSearchType);
            addParameter(p, 'K', 25, validGreaterThanZero);
            addParameter(p, 'Power', 2, validGreaterThanZero);
            addParameter(p, 'DistanceType', 'euclidean', validDistanceType);
            parse(p, varargin{:});
            
            % Retrieve the members from the inputParser            
            obj.power = p.Results.Power;            
            obj.searchObj = QueryNeighborhood(obj.data, 'Radius', p.Results.Radius, ...
                                                        'SearchType', p.Results.SearchType, ...
                                                        'K', p.Results.K, ...
                                                        'DistanceType', p.Results.DistanceType);
        end
        
        function z = interpolate(obj, x, y)            
            Interpolant.checkSizes(x, y);            
            
            [ind, distances] = obj.searchObj.getNeighbors(x, y);
            
            z = zeros(size(x));
            for i = 1:numel(ind)
                zi = obj.data(ind{i}, 3)';
                d = distances{i};
                if min(d) < 0.0001
                   z(i) = zi(1); % The one with minimum distance is the first, according to rangesearch/knnsearch documentation
                   continue;
                end                
                dw = d.^obj.power;
                diw = 1./dw;
                z(i) = sum(diw.*zi)/sum(diw);
            end
        end        
    end
end

