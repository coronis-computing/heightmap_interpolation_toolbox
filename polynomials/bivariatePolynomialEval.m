function eval = bivariatePolynomialEval(coeffs, x, y)
%BIVARIATEPOLYTERMS Get the terms of a bivariate polynomial function of a
% given degree

if size(x, 2) ~= 1
    error('X and Y must be column vectors');
end
if size(x) ~= size(y)
    error('Sizes of ''x'' and ''y'' must be the same');
end

numCoeffs = numel(coeffs);
if numCoeffs == 0
    eval = zeros(size(x));
    return
end

% Infer the degree of the polynomial from the number of coefficients
switch numCoeffs
    case 1 % Constant
        degree = 0;
    case 3 % Linear
        degree = 1;
    case 6 % Quadratic
        degree = 2;
    case 10 % Cubic
        degree = 3;
    otherwise
        error('Polynomial degree not implemented');
end

% Get the terms of this polynomial
terms = bivariatePolynomialTerms(degree, x, y);

% Evaluate using coefficients
eval = terms*coeffs;
    
end

