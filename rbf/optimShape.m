function [e, res, testInd, validationInd] = optimShape(x, y, z, rbfType, validationPercent, eInit, options)
%OPTIMSHAPE Finds the optimal shape parameter of a RBF. Also returns the optimal
%interpolant
% 
% Given known input data, it uses a percentage of this data 
% (1-validationPercent) to create an interpolant. Then, it uses the rest of
% the data to validate the interpolant accuracy (using Sum of Squared
% Differences). This function is used in a non-linear optimization to seek
% for the optimal 'e' (shape parameter of some RBF)
% 

if strcmpi(rbfType, 'linear') || ...
    strcmpi(rbfType, 'cubic') || ...
    strcmpi(rbfType, 'quintic') || ...
    strcmpi(rbfType, 'thinplate') || ...
    strcmpi(rbfType, 'green') 
    error('%s RBF does not require a shape parameter!', rbfType);
end

if numel(x) ~= numel(y) || numel(x) ~= numel(z)
    error('The number of elements in x, y, z must be the same!');
end

if validationPercent <= 0 || validationPercent >= 1
    errro('validationPercent must be specified as a number between 0 and 1 (non-inclusive)');
end

% Separate the reference data into test and validation
numValid = ceil(numel(x)*validationPercent);
rp = randperm(length(x));
validationInd = rp(1:numValid);
testInd = rp(numValid+1:end);

% Test data
xt = x(testInd);
yt = y(testInd);
zt = z(testInd);

% Validation data
xv = x(validationInd);
yv = y(validationInd);
zv = z(validationInd);

% Optimize
objectiveFun = @(e) residuals(xt, yt, zt, xv, yv, zv, options, rbfType, e);
          
% We turn off the MATLAB:nearlySingularMatrix warning, as it will happen a
% lot during optimization
warning('off', 'MATLAB:nearlySingularMatrix');

% Minimize
% optimOptions = optimset('MaxFunEvals', 10000000, 'TolFun', 1e-10, 'TolX', 1e-10);           
optimOptions = optimset('MaxFunEvals', 10000000);
[e, res, exitflag, output] = fminsearch(objectiveFun, eInit, optimOptions);

% Turn on the warning again
warning('on', 'MATLAB:nearlySingularMatrix');
end


function res = residuals(xt, yt, zt, xv, yv, zv, options, rbfType, e)
% Input:
%   - xt, yt, zt: test values
%   - xv, yv, zv: validation values
%
% Output:
%   - res = summed residuals

rbfInterp = RBFInterpolant(xt, yt, zt, 'DistanceType', options.DistanceType, ...
                                       'PolynomialDegree', options.RBF.(rbfType).PolynomialDegree, ...
                                       'RBF', rbfType, ...
                                       'RBFEpsilon', e, ... 
                                       'Smooth', options.RBF.(rbfType).Smooth, ...
                                       'Regularization', options.RBF.(rbfType).Regularization);
zi = rbfInterp.interpolate(xv, yv);

res = sum(abs(zv-zi));

end