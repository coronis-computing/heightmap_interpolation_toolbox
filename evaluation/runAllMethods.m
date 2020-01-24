function [zis, runTimes] = runAllMethods(x, y, z, xi, yi, options)
% runAllMethods

if nargin < 6 || isempty(options)
    % Load them from file, first check if there is a specific options file
    % in the current folder
    if exist('hitOptions.m', 'file')
        hitOptions
    else
        warning('Using default parameters!');
    end    
end

% Run all methods available
interp = NearestNeighborInterpolant(x, y, z);

