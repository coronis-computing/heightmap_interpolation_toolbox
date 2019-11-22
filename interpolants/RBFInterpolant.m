classdef RBFInterpolant < Interpolant
    %RBFINTERPOLANT Interpolant using Radial Basis Functions
    %  
    
    properties
        weights; % The weights of the RBF equation
        poly; % The constant polynomial part
        distFun; % Distance functor
        rbfFun; % RBF functor
    end
    
    methods
        function obj = RBFInterpolant(x, y, z, varargin)
            %RBFINTERPOLANT Construct an instance of this class
            %   Detailed explanation goes here
            
            % Superclass constructor
            obj@Interpolant(x, y, z);
            
            % Validation functions for the input parameters
            validDistanceType = @(x) ischar(x) && strcmpi(x, 'euclidean') || strcmpi(x, 'haversine');
            validPolynomialDegree = @(x) isscalar(x) && x < 0 || x == 0 || x == 1;
            validRBFType = @(x) isa(x, 'function_handle') || ...
                                (ischar(x) && strcmpi(x, 'multiquadric') || ...
                                              strcmpi(x, 'thinplate') || ...
                                              strcmpi(x, 'inversemultiquadric') || ...
                                              strcmpi(x, 'green') || ...
                                              strcmpi(x, 'gaussian'));
            
            % Check the input parameters using inputParser
            p = inputParser;
            addParameter(p, 'DistanceType', 'euclidean', validDistanceType);
            addParameter(p, 'PolynomialDegree', 0, validPolynomialDegree);
            addParameter(p, 'RBF', 'multiquadric', validRBFType);
            addParameter(p, 'RBFSmoothTerm', 0, @isscalar);
            parse(p, varargin{:});
                    
            % Get the distanceFunctor
            distanceType = p.Results.DistanceType;
            if strcmpi(distanceType, 'euclidean')
                obj.distFun = @(x, y) vecnorm(x-y, 2, 2);
            elseif strcmpi(distanceType, 'haversine')
                obj.distFun = @haversine;
            else 
                error('Unknown DistanceType');
            end
           
            % Get the RBF functor
            rbfType = p.Results.RBF;
            if isa(rbfType, 'function_handle')
                obj.rbfFun = rbfType;
            else
                switch lower(rbfType)
                    case 'multiquadric'
                        obj.rbfFun = @(x) multiQuadricRBF(x, p.Results.RBFSmoothTerm);
                    case 'thinplate'
                        obj.rbfFun = @(x) thinPlateSplineRBF(x);    
                    case 'inversemultiquadric'
                        obj.rbfFun = @(x) inverseMultiQuadricRBF(x, p.Results.RBFSmoothTerm);    
                    case 'green'
                        obj.rbfFun = @(x) greenRBF(x);                    
                    case 'gaussian'
                        obj.rbfFun = @(x) gaussianRBF(x, p.Results.RBFSmoothTerm);                    
                    otherwise
                        error('Unknown RBFType');
                end
            end
            
            % Functor
            [obj.weights, obj.poly] = RBFInterpolant.solveWeightsAndPoly(x, y, z, obj.distFun, obj.rbfFun, p.Results.PolynomialDegree);
        end
        
        function z = interpolate(obj, x, y)
            %INTERPOLATE Summary of this method goes here
            %   Detailed explanation goes here
            
            % Check input sizes
            Interpolant.checkSizes(x, y);
            
            % Evaluate the RBF at the input points
            numPts = size(obj.data, 1);
            numQueryPts = numel(x);
            z = zeros(size(x));
            for q = 1:numQueryPts
                queryPt = [x(q), y(q)];
                for i = 1:numPts
                    z(q) = z(q) + obj.weights(i)*obj.rbfFun(obj.distFun(obj.data(i, 1:2), queryPt));
                end
            end
        end
    end
    
    methods (Static)
        function [weights, poly] = solveWeightsAndPoly(x, y, z, distFun, rbfFun, polynomialDegree)
            % Redundant check, since this would have returned a warning in
            % the constructor of the superclass, which is called before
            % this function. Still, since we made the function static, we
            % leave here this check just in case...
            if numel(x) ~= numel(y) || numel(x) ~= numel(z)
                error('The number of elements in x, y and z must be the same');
            end
            
            % Get the number of unknowns/variables of the polynomial part
            if polynomialDegree < 0
                numPolyUnknowns = 0;
            elseif polynomialDegree == 0
                numPolyUnknowns = 1; % i.e., the polynomial part is a constant
            elseif polynomialDegree == 1
                numPolyUnknowns = 3; % i.e., coefficients of A+B*x+C*y                
            end
            
            % Compose the system of equations
            numSamples = size(x, 1);
            A = zeros(numSamples, numSamples);
            for i = 1:numSamples
                for j = 1:numSamples
                    A(i, j) = rbfFun(distFun([x(i), y(i)], [x(j), y(j)]));
                end
            end
            b = z(:);
            if numPolyUnknowns > 0
                if numPolyUnknowns == 1
                   A(:, end+1) = 1;
                   A(end+1, :) = 1;
                   A(end, end) = 0;
                   b(end+1) = 0;
                else % numPolyUnknowns == 3
                   A(:, end+1:end+3) = [x(:), y(:), ones(numSamples, 1)]; 
                   A(end+1:end+3, :) = [[x(:), y(:), ones(numSamples, 1)]' zeros(3,3)]; 
                   b(end+1:end+3) = 0;
                end                
            end
            
            % Solve it
            solution = A\b;
            
            % Recover the results
            weights = solution(1:numSamples);
            if polynomialDegree >= 0
                poly = solution(numSamples+1:end);
            else
                poly = [];
            end
        end
    end
end

