classdef MLSInterpolant < Interpolant
    %MLSINTERPOLANT Local interpolant using Moving Least Squares
    
    properties        
        polyDeg; % The polynomial degree to be fitted
        rbfFun; % RBF functor
        searchObj; % The search object 
        minSamples; % The minimum number of samples required in the neighborhood of a point so that the fit is possible
    end
    
    methods
        function obj = MLSInterpolant(x, y, z, varargin)
            %MLSINTERPOLANT Construct an instance of this class
            %   Detailed explanation goes here
            
            % Superclass constructor
            obj@Interpolant(x, y, z);
            
            % Validation functions for the input parameters
            validDistanceType = @(x) ischar(x) && strcmpi(x, 'euclidean') || strcmpi(x, 'haversine');
            validPolynomialDegree = @(x) isscalar(x) && x >= 0 && x < 3; % Interpolate up to 3rd degree polynomial
            validRBFType = @(x) isa(x, 'function_handle') || ...
                                (ischar(x) && strcmpi(x, 'wendland'));
            validMinNumSamples = @(x) isscalar(x) && x > 0;
            
            % Check the input parameters using inputParser
            p = inputParser;
            addParameter(p, 'DistanceType', 'euclidean', validDistanceType);
            addParameter(p, 'PolynomialDegree', 0, validPolynomialDegree);            
            addParameter(p, 'RBF', 'wendland', validRBFType); % Note: this should be a compactly-supported RBF
            addParameter(p, 'RBFEpsilon', 1, @isscalar); % In this case, this parameter represents the support of the RBF and the range search query!             
            addParameter(p, 'MinSamples', 10, validMinNumSamples);
            parse(p, varargin{:});
            
            % Get the RBF functor
            obj.rbfFun = rbfTypeToFunctor(p.Results.RBF, p.Results.RBFEpsilon);
            
            % Get the polynomial degree to fit
            obj.polyDeg = p.Results.PolynomialDegree;
            
            % Get the minimum number of points
            obj.minSamples = p.Results.MinSamples;
            
            % Check that the minimum number of samples desired is larger
            % than the minimum number of samples that correspond to the
            % selected polynomial degree
            coeffs = bivariatePolynomialTerms(obj.polyDeg, 1, 1);
            if obj.minSamples < numel(coeffs)
                warning('The minimum number of samples set (%d) is less than the minimum number of samples that correspond to the selected polynomial degree. Settin the minimum number of samples to %d!', obj.minSamples, numel(coeffs));
                obj.minSamples = numel(coeffs);
            end
            
            % Create the search object
            obj.searchObj = QueryNeighborhood(obj.data, 'Radius', p.Results.RBFEpsilon, ...
                                                        'SearchType', 'radial', ...
                                                        'DistanceType', p.Results.DistanceType);
        end
        
        function z = interpolate(obj, x, y)
            %INTERPOLATE MLS interpolates 
            
            % Check input sizes
            Interpolant.checkSizes(x, y);
            
            % Get the neighbor points within the support for each input query point
            [ind, distances] = obj.searchObj.getNeighbors(x, y);
            
            z = zeros(size(x));
            for i = 1:numel(ind)
                % The set of neighboring points
                neighData = obj.data(ind{i}, :);
                
                % Check if there is a minimum number of points in the
                % neighborhood
                if size(neighData, 1) < obj.minSamples
                    z(i) = NaN; % Undefined value
                    continue;
                end
                
                % Solve the local MLS fitting
                polyCoeffs = obj.solveSingleMLS(neighData(:, 1), neighData(:, 2), neighData(:, 3), distances{i});
                
                % Evaluate the local polynomial at the query point
                polyTerms = bivariatePolynomialTerms(obj.polyDeg, x(i), y(i));
                z(i) = polyTerms*polyCoeffs;
            end        
        end
        
        function polyCoeffs = solveSingleMLS(obj, x, y, z, dist)
            
            numSamples = size(x, 1);
            
            % Construct matrix containing the terms
            P = bivariatePolynomialTerms(obj.polyDeg, x(:), y(:));
            
            % and the matrix constructed with weights
            W = zeros(numSamples);
            W(logical(eye(numSamples))) = obj.rbfFun(dist);
            
            % Solve the local fit
            A = P'*W*P;
            B = P'*W;
            polyCoeffs = inv(A)*B*z;
            
        end
    end
end

