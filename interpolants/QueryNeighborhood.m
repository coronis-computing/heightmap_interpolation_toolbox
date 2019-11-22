classdef QueryNeighborhood
    %QUERYNEIGHBORHOOD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data;
        searchType;
        distanceType;
        searchKNN;
        searchRadius
    end
    
    methods
        function obj = QueryNeighborhood(data, varargin)
            % Validator functors
            validData = @(x) size(x, 1) > 0 && size(x, 2) == 3;
            validScalarGreaterThanZero = @(x) isscalar(x) && x > 0;
            validSearchType = @(x) ischar(x) && strcmpi(x, 'radial') || strcmpi(x, 'knn');
            validDistanceType = @(x) ischar(x) && strcmpi(x, 'euclidean') || strcmpi(x, 'haversine');
            
            % Parse the parameters using inputParser
            p = inputParser;
            addRequired(p, 'data', validData);
            addParameter(p, 'Radius', 5, validScalarGreaterThanZero);    
            addParameter(p, 'SearchType', 'radial', validSearchType);
            addParameter(p, 'K', 25, validScalarGreaterThanZero);
            addParameter(p, 'DistanceType', 'euclidean', validDistanceType);
            parse(p, data, varargin{:});
            
            % Retrieve the members from the inputParser
            obj.data = p.Results.data;
            obj.searchRadius = p.Results.Radius;
            obj.searchKNN = p.Results.K;
            obj.searchType = p.Results.SearchType;
            obj.distanceType = p.Results.DistanceType;
        end
        
        function [ind, distances] = getNeighbors(obj, x, y)
            %%Get the neighbors to a query point
            if strcmpi(obj.searchType, 'radial')
                if strcmpi(obj.distanceType, 'euclidean')
                    [ind, distances] = rangesearch(obj.data(:, 1:2), [x(:) y(:)], obj.searchRadius);
                else
                    [ind, distances] = rangesearch(obj.data(:, 1:2), [x(:) y(:)], obj.searchRadius, 'Distance', @haversine);
                end
            else
                if strcmpi(obj.distanceType, 'euclidean')
                    [ind, distances] = knnsearch(obj.data(:, 1:2), [x(:) y(:)], 'K', obj.searchKNN);
                else
                    [ind, distances] = knnsearch(obj.data(:, 1:2), [x(:) y(:)], 'K', obj.searchKNN, 'Distance', @haversine);
                end
                % For consistency with range search
                ind = num2cell(ind, 2);
                distances = num2cell(distances, 2);
            end
        end
    end
end

