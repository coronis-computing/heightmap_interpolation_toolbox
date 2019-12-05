classdef RBFInterpolant < Interpolant
    %RBFINTERPOLANT Interpolant using Radial Basis Functions
    
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
            validPolynomialDegree = @(x) isscalar(x) && x <= 3;
            validRBFType = @(x) isa(x, 'function_handle') || ...
                                (ischar(x) && strcmpi(x, 'linear') || ...                                              
                                              strcmpi(x, 'cubic') || ...
                                              strcmpi(x, 'quintic') || ...
                                              strcmpi(x, 'multiquadric') || ...
                                              strcmpi(x, 'inversemultiquadric') || ...
                                              strcmpi(x, 'thinplate') || ...
                                              strcmpi(x, 'green') || ...
                                              strcmpi(x, 'tensionspline') || ...
                                              strcmpi(x, 'regularizedspline') || ...
                                              strcmpi(x, 'gaussian') || ...
                                              strcmpi(x, 'wendland'));
            
            % Check the input parameters using inputParser
            p = inputParser;
            addParameter(p, 'DistanceType', 'euclidean', validDistanceType);
            addParameter(p, 'PolynomialDegree', 0, validPolynomialDegree);
            addParameter(p, 'RBF', 'multiquadric', validRBFType);
            addParameter(p, 'RBFEpsilon', 1, @isscalar); % The additional parameter of some RBF
            addParameter(p, 'Smooth', 0, @isscalar); % The smoothing parameter (set it to something >0 for APPROXIMATE instead of INTERPOLATE)
            addParameter(p, 'Regularization', 0, @isscalar); % Regularization coefficient to avoid matrix being close to singular (specially needed when using gaussianRBF)            
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
            obj.rbfFun = rbfTypeToFunctor(p.Results.RBF, p.Results.RBFEpsilon);
                        
            % Functor
            [obj.weights, obj.poly] = RBFInterpolant.solveWeightsAndPoly(x, y, z, obj.distFun, obj.rbfFun, p.Results.PolynomialDegree, p.Results.Smooth, p.Results.Regularization);
        end
        
        function z = interpolate(obj, x, y)
            %INTERPOLATE Summary of this method goes here
            %   Detailed explanation goes here
            
            % Check input sizes
            Interpolant.checkSizes(x, y);
            
            % Evaluate the RBF at the input points
            % Slower version, left here for reference (more readable)
%             numPts = size(obj.data, 1);
%             numQueryPts = numel(x);
%             numPolyCoeffs = numel(obj.poly);
%             z = zeros(size(x));            
%             for q = 1:numQueryPts
%                 queryPt = [x(q), y(q)];
%                 % Polynomial part
%                 if numPolyCoeffs > 0
%                     if numPolyCoeffs == 1
%                         z(q) = obj.poly(1);
%                     elseif numPolyCoeffs == 3
%                         z(q) = queryPt*obj.poly(1) + queryPt*obj.poly(2) + obj.poly(3);
%                     end
%                 end
%                 for i = 1:numPts                                        
%                     z(q) = z(q) + obj.weights(i)*obj.rbfFun(obj.distFun(obj.data(i, 1:2), queryPt));
%                 end
%             end

            % Faster version
            % Compute all pair-wise distances
            dists = pdist2([x(:) y(:)], obj.data(:, 1:2), obj.distFun);
            
            % Evaluate the RBF for all the distances
            A = obj.rbfFun(dists);
%             
%             numPolyCoeffs = numel(obj.poly);
%             if numPolyCoeffs > 0
%                 if numPolyCoeffs == 1
%                    A(:, end+1) = 1;
%                    A(end+1, :) = 1;
%                    A(end, end) = 0;
%                 else % numPolyUnknowns == 3
%                    A(:, end+1:end+3) = [x(:), y(:), ones(numel(x), 1)]; 
%                    A(end+1:end+3, :) = [[x(:), y(:), ones(numel(x), 1)]' zeros(3,3)]; 
%                 end                
%             end

            polyEval = bivariatePolynomialEval(obj.poly, x(:), y(:));
            
            z = A*obj.weights + polyEval;
            z = reshape(z, size(x));
        end
    end
    
    methods (Static)
        function [weights, poly] = solveWeightsAndPoly(x, y, z, distFun, rbfFun, polynomialDegree, smooth, regularizationCoeff)
            % Redundant check, since this would have returned a warning in
            % the constructor of the superclass, which is called before
            % this function. Still, since we made the function static, we
            % leave here this check just in case...
            if numel(x) ~= numel(y) || numel(x) ~= numel(z)
                error('The number of elements in x, y and z must be the same');
            end
            numSamples = size(x, 1);
            
            % Compose the system of equations (slower, but more readable version, we leave it here commented for reference)
%             A = zeros(numSamples, numSamples);
%             for i = 1:numSamples
%                 for j = 1:numSamples
%                     A(i, j) = rbfFun(distFun([x(i), y(i)], [x(j), y(j)]));
%                 end
%             end
            
            % Compute all pair-wise distances
            dists = pdist([x y], distFun);
            
            % Evaluate the RBF for all the distances
            rbfEvals = rbfFun(dists);
            
            % Compose the system of equations
            % - RBF part
            A = zeros(numSamples, numSamples);
            A(tril(true(numSamples, numSamples), -1)) = rbfEvals; % Fill the lower triangular part of the matrix
            A = A + A'; % Mirror over the diagonal (matrix A is symmetric)
            % Compute RBF values at the diagonal (rbf(0))
            A(logical(eye(numSamples))) = rbfFun(0);

            % Smoothing?
            if smooth ~= 0
                A = A - eye(numSamples)*smooth;
            end

            % Regularizer?
            if regularizationCoeff ~= 0
                A = A + eye(size(A, 1))*regularizationCoeff;
            end
            
            b = z(:);
            
            % - Polynomial part
            terms = bivariatePolynomialTerms(polynomialDegree, x(:), y(:));
            numTerms = size(terms, 2);
            A(:, end+1:end+numTerms) = terms;
            A(end+1:end+numTerms, :) = [terms' zeros(numTerms, numTerms)];
            b(end+1:end+numTerms) = 0;

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

