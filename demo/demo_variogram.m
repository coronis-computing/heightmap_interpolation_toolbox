clear all; close all;
%% Load some scattered data
load seamount;

%% Create the raster grid
[xi, yi] = meshgrid(210.8:0.01:211.8, -48.5:0.01:-47.9);

%% Create the variogram
vg = Variogram(x, y, z, 'model', 'gaussian', 'NumBins', 100, 'OptimNugget', true);
vg.plot();
