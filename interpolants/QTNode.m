classdef QTNode
    %Quadtree Partition of Unity RBF Node
    
    properties
        x; % Center of the node in X
        y; % Center of the node in Y
        w; % Width of the node
        h; % Height of the node
        pts = []; % Points in this node (of size numPts x 3)
        childs = []; % Children of the node (up to 4)
        rbfInterp = []; % The interpolator function (just computed at leaves)
        weightingRBF = []; % The weighting CSRBF
        distFun; % Distance function between points in the XY plane
        overlap; % Amount of overlap between circles (scalar between 0 and 1). The base radius of a cell (overlap = 0) in the QuadTree corresponds to half the length of its diagonal. This parameter is a multiplicative factor applied to this base radius.
    end
    
    methods
        function obj = QTNode(x, y, w, h, pts, distFun, overlap)
            % Constructor of the class
            obj.x = x; 
            obj.y = y;
            obj.w = w;
            obj.h = h;            
            obj.childs = [];      
            obj.distFun = distFun;
            obj.overlap = overlap;
            
            % From the input points, just retain those within the limits
            ind = obj.ptsInNodeCircle(pts);
            obj.pts = pts(ind, :);            
        end
                
        function center = getCenter(obj)
            %getCenter Gets the center point of the node
            center = [obj.x+(obj.w/2), obj.y+(obj.h/2)];
        end
        
        function radius = getRadius(obj)
            %getRadius Gets the radius of the node using the internal
            %distance function (required while evaluating the RBF)
            %   it also applies the "overlap" factor
            diag = getDiagonalLength(obj);
            radius = diag*0.5;
            radius = radius+radius*obj.overlap;
        end
        
        function diagLength = getDiagonalLength(obj)
            %getDiagonalLength Gets the length of the diagonal of the square represented by
            % the node
            diagLength = obj.distFun([obj.x+obj.w, obj.y+obj.h], [obj.x, obj.y]);
        end
        
        function diagLength = getEuclideanDiagonalLength(obj)
            %getDiagonalLength Gets the length of the diagonal of the square represented by
            % the node
            diagLength = norm([obj.x+obj.w, obj.y+obj.h]-[obj.x, obj.y]);
        end
        
        function radius = getEuclideanRadius(obj)
            %getRadius Gets the radius of the node using Euclidean distance
            %on the XY plane
            %   it also applies the "overlap" factor
            diag = getEuclideanDiagonalLength(obj);
            radius = diag*0.5;
            radius = radius+radius*obj.overlap;            
        end
        
        function b = isLeaf(obj)
            b = isempty(obj.childs);
        end
        
        function b = ptsInNodeCircle(obj, pts)
%             center = obj.getCenter();
%             radius = obj.getRadius(overlap);            
%             rads = obj.distFun([x, y], repmat(center, numel(x), 1), 2, 2);
%             b = rads <= radius;
            
                        % Check if the points fall within the circle using Euclidean
            % distance. 
            
            % Keep just those points falling within a circle
            center = obj.getCenter();
            radius = obj.getEuclideanRadius();
            
            rads = vecnorm(pts(:, 1:2)-center, 2, 2);
            b = rads <= radius;
        end
        
        function nodes = getLeaves(node)
            % If the children nodes are empty, this is a leaf
            if node.isLeaf()
                nodes = node;
            else
                nodes = [];
                for i = 1:4
                    nodes = [nodes, getLeaves(node.childs(i))];
                end
            end            
        end
        
        function obj = subdivide(obj, minPts, minCellSideLength)
            %subdivide Recursive subdivision of the Quadtree
            
            % End of recursion if we have less than minimum number of points in the cell 
            if size(obj.pts, 1) < minPts
                return;
            end
            
            % The width/height of children nodes is halved
            w = obj.w/2;
            h = obj.h/2;
            
            % End of recursion if children will have a length smaller than the minimum cell length
            if w < minCellSideLength || h < minCellSideLength
                return;
            end
            
            % Create the 4 childrens and span subdivision
            % South-West node
            swNode = QTNode(obj.x, obj.y, w, h, obj.pts, obj.distFun, obj.overlap);             
            if size(swNode.pts, 1) < minPts
                % We also end recursion if one of the childrens to span has
                % less than minPts, because this would mean that we should
                % not be dividing the current node
                return;
            end
            % North-West node
            nwNode = QTNode(obj.x+w, obj.y, w, h, obj.pts, obj.distFun, obj.overlap);             
            if size(nwNode.pts, 1) < minPts
                return;
            end
            % South-East node
            seNode = QTNode(obj.x, obj.y+h, w, h, obj.pts, obj.distFun, obj.overlap);             
            if size(seNode.pts, 1) < minPts
                return;
            end
            % North-East node
            neNode = QTNode(obj.x+w, obj.y+h, w, h, obj.pts, obj.distFun, obj.overlap); 
            if size(neNode.pts, 1) < minPts
                return;
            end
            
            % Span subdivision
            swNode = swNode.subdivide(minPts, minCellSideLength);
            nwNode = nwNode.subdivide(minPts, minCellSideLength);
            seNode = seNode.subdivide(minPts, minCellSideLength);
            neNode = neNode.subdivide(minPts, minCellSideLength);
            
            obj.childs = [swNode, seNode, nwNode, neNode];
%             obj.pts = []; % Free space, points are stored only at leaves
        end
        
        function obj = computeRBFAtLeafs(obj, varargin)
            if obj.isLeaf()
                % Compute the local RBF interpolant corresponding to this node
                obj.rbfInterp = RBFInterpolant(obj.pts(:, 1), obj.pts(:, 2), obj.pts(:, 3), varargin{:});
                % Create the weighting RBF
                r = obj.getRadius();
                obj.weightingRBF = rbfTypeToFunctor('wendland', r);
            else
                % Recurse down the tree
                for i = 1:4
                    obj.childs(i) = obj.childs(i).computeRBFAtLeafs(varargin{:});
                end
            end
        end
        
        function [f, w] = evalRBF(obj, x, y)
            % Evaluates the RBF value of a point at each intersecting leaf
            % It also returns the weight at the evaluation point
            
            if obj.ptsInNodeCircle([x, y])            
                if obj.isLeaf()
                    % Evaluate the RBF
                    f = obj.rbfInterp.interpolate(x, y);
                    w = obj.weightingRBF(obj.distFun([x, y], obj.getCenter()));
                else
                    % Recurse down the tree
                    f = [];
                    w = [];
                    for i = 1:4
                        [fc, wc] = evalRBF(obj.childs(i), x, y);
                        f = [f; fc];
                        w = [w; wc];
                    end                
                end
            else
                f = [];
                w = [];
            end
        end
        
        function obj = freeMemory(obj)
            % Remove stored points in non-leaf nodes
            %  Use this function after creating the QuadTree (i.e., after
            %  subdivide and correct methods
            
            if isempty(obj.childs)
                % Leaf node, end recursion
                return;
            else
                % Non-leaf node, eliminate points
                obj.pts = [];
                % And follow traversal
                obj.childs(1) = obj.childs(1).freeMemory();
                obj.childs(2) = obj.childs(2).freeMemory();
                obj.childs(3) = obj.childs(3).freeMemory();
                obj.childs(4) = obj.childs(4).freeMemory();
            end
            
        end
    
    end
    
    methods (Static)
        function pts = ptsInNode(x, y, w, h, pts)
            % Keep just those points falling within the node (quad-shape)
            ptsInNodeInds = pts(:, 1) >= x & pts(:, 1) <= x+w & pts(:, 2) >= y & pts(:, 2) <= y+h;
            pts = pts(ptsInNodeInds, :);
        end
        
%         function pts = ptsInNodeCircle(x, y, w, h, pts, overlap)
%             % Check if the points fall within the circle using Euclidean
%             % distance. 
%             
%             % Keep just those points falling within a circle
%             center = [x+(w/2), y+(h/2)];
%             diag = norm([x+w, y+h]-[x, y]);
%             radius = diag*0.5;
%             radius = radius+radius*overlap;
%             
%             rads = vecnorm(pts(:, 1:2)-center, 2, 2);
%             pts = pts(rads <= radius, :);
%         end
    end
end

