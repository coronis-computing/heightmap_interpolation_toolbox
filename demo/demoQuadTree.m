function demoQuadTree(dataId, minPoints, overlap, minCellSizePercent)
%demoQuadTree Simple script showing the partition of unity created by a
%quadtree (QuadTreePURBFInterpolant class)
    
    if nargin < 2
        minPoints = 10;
    end
    if nargin < 3
        overlap = 0.25;
    end
	if nargin < 3
        minCellSizePercent = 0.05;
    end

    %% Parse parameters
    if nargin < 1 || isempty(dataId)
        dataId = 'seamount';
    end

    %% Get the sample data and options
    [x, y, z, ~, ~, ~, ~] = getSampleDataset(dataId);
 
    %% Construct the QuadTree
    qt = QuadTreePURBFInterpolant(x, y, z, 'MinPointsInCell', minPoints, 'Overlap', overlap, 'MinCellSizePercent', minCellSizePercent, 'DistanceType', 'haversine');
    
    %% Plot it
    qt.plot();    
end
