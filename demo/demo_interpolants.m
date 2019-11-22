% clear all; close all;
%% Load some scattered data
load seamount;
% x = -3 + 6*rand(50,1);
% y = -3 + 6*rand(50,1);
% z = sin(x).^4 .* cos(y);

%% Create the raster grid
[xi, yi] = meshgrid(210.8:0.01:211.8, -48.5:0.01:-47.9);
% [xi, yi] = meshgrid(-3:0.1:3);

% Plot original data
plot3(x,y,z,'.');
title('Original Data');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

%% Interpolate with each available method

% Nearest neighbor
nearNeighInterp = NearestNeighborInterpolant(x, y, z);
zi = nearNeighInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('NearestNeighborInterpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

% Delaunay Triangulation
dtInterp = DelaunayTINInterpolant(x, y, z);
zi = dtInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('DelaunayTINInterpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

% Natural Neighbors
naturNeighInterp = NaturalNeighborsInterpolant(x, y, z);
zi = naturNeighInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('NaturalNeighborsInterpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

% IDW interpolant% % Nearest neighbor
nearNeighInterp = NearestNeighborInterpolant(x, y, z);
zi = nearNeighInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('NearestNeighborInterpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

% Delaunay Triangulation
dtInterp = DelaunayTINInterpolant(x, y, z);
zi = dtInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('DelaunayTINInterpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

% Natural Neighbors
naturNeighInterp = NaturalNeighborsInterpolant(x, y, z);
zi = naturNeighInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('NaturalNeighborsInterpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

% IDW interpolant
idwInterp = IDWInterpolant(x, y, z, 'DistanceType', 'haversine', ...
                                    'SearchType', 'knn', ...
                                    'k', 5, ...
                                    'Radius', 0.025, ...
                                    'Power', 1);
zi = idwInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('IDW Interpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');

% RBF interpolant
rbfInterp = RBFInterpolant(x, y, z, 'DistanceType', 'euclidean', ...
                                    'PolynomialDegree', -1, ...
                                    'RBF', 'green', ...
                                    'RBFSmoothTerm', 0.5);
zi = rbfInterp.interpolate(xi, yi);
figure;
surf(xi, yi, zi);
title('RBF Interpolant');
xlabel('Longitude');
ylabel('Latitude');
zlabel('Depth in Feet');