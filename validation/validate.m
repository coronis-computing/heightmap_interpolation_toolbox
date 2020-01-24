function [validationData, stats] = validate(x, y, z, k, options, methods, verbose)
%VALIDATE Cross validation of the methods in the toolbox
% 
% Input:
%   - x, y, z: the known function values of the bivariate function
%       f(x,y)=z.
%   - k: k-fold cross validation.
%   - options: options structure containing the parameters for each method,
%       as returned by the hmitDefaultOptions function.
%   - methods: cell array of char vectors listing the methods to test. If
%       empty or not specified, all the methods in the toolbox will be
%       used.
%   - verbose: show the progress on screen.
% 
% Output:
%   - validationData: structure containing the different tests and results
% 

% Parameters' check
if nargin < 6
    methods = {'Nearest', 'Delaunay', 'Natural', 'IDW', 'Kriging', 'MLS', ...
               'RBF.linear', 'RBF.cubic', 'RBF.quintic', 'RBF.multiquadric', 'RBF.thinplate', 'RBF.green', 'RBF.tensionspline', 'RBF.regularizedspline', 'RBF.gaussian', 'RBF.wendland', ...
               'QTPURBF.linear', 'QTPURBF.cubic', 'QTPURBF.quintic', 'QTPURBF.multiquadric', 'QTPURBF.thinplate', 'QTPURBF.green', 'QTPURBF.tensionspline', 'QTPURBF.regularizedspline', 'QTPURBF.gaussian', 'QTPURBF.wendland'};
end
if nargin < 7
    verbose = true;
end

numPts = numel(x);
if k == 1
    % Leave One Out Cross Validation
    inds = 1:numPts;
    k = numPts;
    if verbose, fprintf('--- LOOCV ---\n'); end
else
    inds = crossvalind('Kfold', 1:numPts, k);
    if verbose, fprintf('--- %d-Fold Cross Validation ---\n', k); end
end

for i = 1:k
    if verbose, fprintf('- Step %d/%d\n', i, k); end
    % Split into test and train data
    validationData(i).test = (inds == i);    
    validationData(i).train = ~validationData(i).test;
    xx = x(validationData(i).train);
    yy = y(validationData(i).train);
    zz = z(validationData(i).train);
    xi = x(validationData(i).test);
    yi = y(validationData(i).test);
    ziRef = z(validationData(i).test);
    for m = 1:numel(methods)
        % Compute the results for the desired method
        method = methods{m};
        if verbose, fprintf('  - Interpolating with %s...', method); end
        tic
        zi = interpolate(xx, yy, zz, xi, yi, method, options);
        t = toc;
        if verbose, fprintf('done, %f sec\n', t); end
        absDiff = abs(zi-ziRef);
        meanAbsDiff = mean(absDiff);
        stdAbsDiff = std(absDiff);
        runTime = t;
        
        % Store this data in the validation structure
        splMethod = regexp(method, '\.', 'split');                
        str = struct('zi', zi, 'absDiff', absDiff, 'meanAbsDiff', meanAbsDiff, 'stdAbsDiff', stdAbsDiff, 'runTime', runTime);
        if numel(splMethod) == 1
            validationData(i).(splMethod{1}) = str;
        else
            validationData(i).(splMethod{1}).(splMethod{2}) = str;
        end        
    end
end

% Compute the stats for each method
for m = 1:numel(methods)
    % Compute the results for the desired method
    method = methods{m};
    splMethod = regexp(method, '\.', 'split');                
    
    % All mean results
    allMeans = zeros(1, k);
    allRunTimes = zeros(1, k);
    for j = 1:k
        if numel(splMethod) == 1
            allMeans(j) = validationData(i).(splMethod{1}).meanAbsDiff;
            allRunTimes(j) = validationData(i).(splMethod{1}).runTime;
        else
            allMeans(j) = validationData(i).(splMethod{1}).(splMethod{2}).meanAbsDiff;
            allRunTimes(j) = validationData(i).(splMethod{1}).(splMethod{2}).runTime;
        end
    end
    
    if numel(splMethod) == 1
        stats.(splMethod{1}).meanAbsDiff = mean(allMeans(j));
        stats.(splMethod{1}).stdAbsDiff = std(allMeans(j));
        stats.(splMethod{1}).meanRunTime = mean(allRunTimes(j));
    else
        stats.(splMethod{1}).(splMethod{2}).meanAbsDiff = mean(allMeans(j));
        stats.(splMethod{1}).(splMethod{2}).stdAbsDiff = std(allMeans(j));
        stats.(splMethod{1}).(splMethod{2}).meanRunTime = mean(allRunTimes(j));
    end
end

