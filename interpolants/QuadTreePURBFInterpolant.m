classdef QuadTreePURBFInterpolant < Interpolant
    %QUADTREE QuadTreePURBFInterpolator class
    % This simplified implementation assumes all the points are known at construction
    % time, and no new insertions are expected after the initial construction
    
    properties
        root; % Root node of the tree (of type QTNode)
        minPts; % Minimum number of points in a QTNode                
        weightingRBF; % The RBF used to compute the Sheppard's weights of the Partition of Unity
        distFun; % Distance function between points in the XY plane
    end
    
    methods
        function obj = QuadTreePURBFInterpolant(x, y, z, varargin)
            %QUADTREE Constructor of the class
            
            % Superclass constructor
            obj@Interpolant(x, y, z);
            
            % Check the input parameters using inputParser
            paramsToDelete = {'PolynomialDegree', 'RBF', 'RBFEpsilon', 'Smooth', 'Regularization'};
            vararginA = deleteParamsFromVarargin(paramsToDelete, varargin);
                        
            p = inputParser;
            validOverlap = @(x) isscalar(x) && x >= 0;
            validDistanceType = @(x) ischar(x) && strcmpi(x, 'euclidean') || strcmpi(x, 'haversine');
            validDomain = @(x) numel(x) == 4;
            addParameter(p, 'MinPointsInCell', 25, @isscalar); % The minimum number of points in a QuadTree cell
            addParameter(p, 'Overlap', 0.25, validOverlap); % Overlap between circles            
            addParameter(p, 'DistanceType', 'euclidean', validDistanceType);
            addParameter(p, 'Domain', [], validDomain); % 4-elements vector specifying the bounding box of the query domain [xmin, ymin, width, height], so that the QuadTree is forced to cover the defined area and no query point gets out of the domain
            parse(p, vararginA{:});
            
            obj.minPts = p.Results.MinPointsInCell;
            overlap = p.Results.Overlap;
            domain = p.Results.Domain;
            
            distanceType = p.Results.DistanceType;
            if strcmpi(distanceType, 'euclidean')
                obj.distFun = @(x, y) vecnorm(x-y, 2, 2);
            elseif strcmpi(distanceType, 'haversine')
                obj.distFun = @haversine;
            else 
                error('Unknown DistanceType');
            end
            
            % Remove this parameters from varargin, as that variable will
            % be used later on to create the local RBF interpolator objects
            paramsToDelete = {'MinPointsInCell', 'Overlap', 'Domain'};
            vararginB = deleteParamsFromVarargin(paramsToDelete, varargin);
            
            % Compute the extents of the root node
            if isempty(domain)
                % Compute the extend of the domain to be that of the input
                % points
                minX = min(obj.data(:, 1)); maxX = max(obj.data(:, 1));
                minY = min(obj.data(:, 2)); maxY = max(obj.data(:, 2));
                w = maxX-minX;
                h = maxY-minY;
            else
                minX = domain(1);
                minY = domain(2);
                w = domain(3);
                h = domain(4);
            end
            
            % We want the space to be divided in squares, so we force the
            % width and height of the root node to be square!
            wh = max([w, h]);
            
            obj.root = QTNode(minX, minY, wh, wh, obj.data, obj.distFun, overlap);
            
            % Subdivide the root node (and effectively create the tree top to bottom)
            obj.root = obj.root.subdivide(obj.minPts);
            
            % Correct the tree (some of the nodes may contain less than the
            % minimum required number of points)
            [obj.root, someCorrection] = obj.root.correct(obj.minPts);
            while someCorrection
                [obj.root, someCorrection] = obj.root.correct(obj.minPts);
            end
            
            % Remove stored points in non-leaf nodes, from now on we will
            % just use leaves
            obj.root.freeMemory();
            
            % Compute a local RBF interpolator for each leaf
            obj.root = obj.root.computeRBFAtLeafs(vararginB{:});            
        end
        
        function plot(obj, newFigure)
            % Plot the quadtree
            if nargin < 2
                newFigure = false;
            end
            if newFigure
                figure();
            end
            hold on;
            nodes = getLeaves(obj.root);
            for i = 1:numel(nodes)
                hold on;
                rectangle('Position', [nodes(i).x, nodes(i).y, nodes(i).w, nodes(i).h]);
                hold off;
                cx = nodes(i).x + (nodes(i).w/2);
                cy = nodes(i).y + (nodes(i).h/2);                
                r = nodes(i).getEuclideanRadius();
                
                plotCircle(cx, cy, r);
%                 hold on;
%                 plot(nodes(i).pts(:, 1), nodes(i).pts(:, 2), '.');    
%                 hold off;
%                 pause;
            end
            hold on;
            plot(obj.data(:, 1), obj.data(:, 2), '.k');
            hold off;      
            axis equal;
        end        
        
        function z = interpolate(obj, x, y)
            %interpolate Interpolates the z value at the x, y points.
            % Note: A NaN value will be generated for those points not
            % covered in the domain of the QuadTree.
            
            % Check input sizes
            Interpolant.checkSizes(x, y);
            
            % Reshape input, for convenience
            orSize = size(x);
            x = x(:);
            y = y(:);
            
%             % Evaluate the RBF of each point (version traversing the tree for each point, very slow, left here for reference)
%             numPts = numel(x);
%             z = ones(numel(x), 1);
%             for i = 1:numPts
%                 % Evaluate the point in the RBF of each point
%                 [f, w] = obj.root.evalRBF(x(i), y(i), obj.overlap);
%                 
%                 if isempty(f)
%                     % The query point is out of range, set it to an invalid
%                     % value
%                     z(i) = NaN;
%                     continue;
%                 end
%                 
%                 % Compute the Weighting function for each               
%                 w = w ./ sum(w);
%                 
%                 % Weight the contribution of each RBF evaluation
%                 z(i) = sum(w.*f);
%             end

            % Evaluate the RBF of each point (version accessing the leaves at once, way faster)

            % Get the leaf nodes
            leaves = getLeaves(obj.root);
            
            % Compute the centers and radius of each leaf
            numLeaves = numel(leaves);
            centers = zeros(numLeaves, 2);
            radius = zeros(numLeaves, 1);
            for i = 1:numLeaves
                centers(i, :) = leaves(i).getCenter();
                radius(i) = leaves(i).getRadius();                
            end
            
            dists = pdist2([x, y], centers, obj.distFun); % We take advantage of the distance function being part of each RBF to avoid using another attribute in this class
%             dists = pdist2([x, y], centers); 
            
            f = zeros(numel(x), 1); % We will store here the accumulation of each RBF contribution (weighted locally)
            w = zeros(numel(x), 1); % And here the accomulation of the weighting function
            for i = 1:numLeaves
                % Find those input points falling in the current leaf
                ind = dists(:, i) <= radius(i);
                
                % Compute the RBF value at those points
                rbfEval = leaves(i).rbfInterp.interpolate(x(ind), y(ind));
                
                % Compute the weighting function at those points
                weights = leaves(i).weightingRBF(dists(ind, i));
                
                % Apply the weights to the corresponding function and
                % accomulate
                f(ind) = f(ind) + rbfEval.*weights;
                
                % Accumulate the weights for the final division
                w(ind) = w(ind)+weights;
            end
            z = f./w; % Here a division by w = 0 will occur for those points outside the domain covered by the quadtree. Since this will result in a NaN, we use this value as an indicator that the z is undefined at that point.
            
            % Get z back to the original shape of the input
            z = reshape(z, orSize);
        end
    end
end

