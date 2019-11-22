classdef Variogram
    %VARIOGRAM Fits a variogram to the modelled data
    
    properties
        a; % a parameter of the variogram model
        c0; % c0 parameter of the variogram model
        c1; % c1 parameter of the variogram model
        model; % The model of fitted variogram
        variogramFun; % The fitted variogram function
        hExp; % Experimental h values
        gammaExp; % Experimental gamma values
        optimNugget;
    end
    
    methods
        function obj = Variogram(x, y, z, varargin)
            %VARIOGRAM Computes a variogram from sample data
            % It fits an experimental semi-variogram, to then fit a
            % variogram function of the three typical parameters (c0, c1, a
            % in the literature, closely related to range, sill and nugget,
            % depending on the model)
            validDistanceType = @(x) ischar(x) && strcmpi(x, 'euclidean') || strcmpi(x, 'haversine');
            validNumBins = @(x) isscalar(x) && x > 0;
            validModelType = @(x) ischar(x) && ...
                                strcmpi(x, 'spherical') || ...
                                strcmpi(x, 'exponential') || ...
                                strcmpi(x, 'gaussian');
            
            p = inputParser;
            addParameter(p, 'DistanceType', 'euclidean', validDistanceType);
            addParameter(p, 'Model', 'spherical', validModelType);
            addParameter(p, 'InitialA', -1, @isscalar);
            addParameter(p, 'InitialC1', -1, @isscalar);
            addParameter(p, 'InitialC0', -1, @isscalar);
            addParameter(p, 'OptimNugget', false, @islogical);
            addParameter(p, 'NumBins', 10, validNumBins);
            parse(p, varargin{:});
            
            obj.optimNugget = p.Results.OptimNugget;
            
            % Compute the experimental variogram
            [obj.hExp, obj.gammaExp] = Variogram.experimentalVariogram(x, y, z, p.Results.NumBins);
            
            % Fit the variogram function to the experimental variogram
            obj = obj.fitModel(p.Results.Model, [p.Results.InitialA, p.Results.InitialC1, p.Results.InitialC0]);
        end
        
        function val = eval(obj, h)
            %Value of the variogram at a given distance
            val = obj.variogramFun(h, [obj.a, obj.c1, obj.c0]);
        end
        
        function obj = fitModel(obj, modelType, initialGuess)
            
            % Selection of the variogram model
            obj.model = modelType;
            switch lower(obj.model)    
                case 'spherical'
                    obj.variogramFun = @(h, b)sphericalVariogramModel(h, b(1), b(2), b(3));
                case 'exponential'
                    obj.variogramFun = @(h, b)exponentialVariogramModel(h, b(1), b(2), b(3));
                case 'gaussian'
                    obj.variogramFun = @(h, b)gaussianVariogramModel(h, b(1), b(2), b(3));
                otherwise
                    error('Unknown variogram model');
            end
            
            % Initial guess
            if initialGuess(1) < 0
                initialGuess(1) = max(obj.hExp)*2/3;
            end
            if initialGuess(2) < 0
                initialGuess(2) = max(obj.gammaExp);
            end
            if initialGuess(3) < 0
                initialGuess(3) = 0; 
            end
                
            % Lower bounds (we use fminsearchbnd instead of the regular fminsearch because this last one may return negative ranges...)
            lb = [0 0 0];
            % Upper bounds
            ub = [inf max(obj.gammaExp) max(obj.gammaExp)];
            if ~obj.optimNugget
                % If the nugget is not to be optimize, set it to 0, as the
                % lower bound, this will remove it from the optimization
                % internally in fminsearchbnd
                ub(3) = 0;
            end
            
            
            
            % Fit the variogram model
            options = optimset('MaxFunEvals', 10000000);
            
            objectiveFun = @(b) sum((obj.variogramFun(obj.hExp, b)-obj.gammaExp).^2);
            
            
            % Minimize
            [b, fval, exitflag, output] = fminsearchbnd(objectiveFun, initialGuess, lb, ub, options);
            
            obj.a = b(1);
            obj.c1 = b(2);
            obj.c0 = b(3);
        end
        
        function plot(obj)
            figure;
            plot(obj.hExp, obj.gammaExp, 'rs','MarkerSize', 10);
            hold on;
            fplot(@(x)obj.variogramFun(x, [obj.a, obj.c1, obj.c0]), [0 max(obj.hExp)]);
            hold off;
        end
    end
    
    methods (Static)
        function [h, g] = experimentalVariogram(x, y, z, numBins)
            %% Computes the experimental ISOTROPIC variogram for a given set of points (x, y) and observations (z)
            
            % Compute all-against-all sample distances
            dists = pdist([x y]);
            
            % Compute the gamma (a bit hacky, we use the gamma function as
            % a distance inside pdist for speed...)
            gammas = pdist(z, @Variogram.gamma);
                        
            % Partition the values into bins according to dists
            edges = linspace(0,max(dists).*.3,numBins+1); % Seen in mGstat semivar_exp
            [N, edges, bin] = histcounts(dists, edges);
            h = edges(2:end)'; % Skip the first element, will be always 0
            
            % Compute the mean gamma for each bin
            g = zeros(numBins, 1);
            for i = 1:numBins
                % Get gamma values in this bin
                gs = gammas(bin == i);
                
                % Get the mean
                g(i) = mean(gs);
            end
        end
        
        function g = gamma(v1, v2)        
           g = 0.5*(v1-v2).^2; 
        end
    end
end

