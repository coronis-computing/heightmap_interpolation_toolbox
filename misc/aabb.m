function box = aabb(pts)
%AABB Computes the Axis-Aligned Bounding Box (AABB) of a set of points in N
%dimensions
% 
% Input:
%   - pts: points matrix, of size numPts x dim.
% 
% Output:
%   - box: AABB of the input points, of the form [xMin, yMin, ... dimMin, sizeX, sizeY, ... sizeDim]
% 

[~, numDims] = size(pts);
box = zeros(1, 2*numDims);
for i = 1:numDims
    minVal = min(pts(:, i));
    maxVal = max(pts(:, i));       
    box(i) = minVal;
    box(i+1+dim) = maxVal-minVal;    
end

