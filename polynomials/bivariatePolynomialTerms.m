function terms = bivariatePolynomialTerms(degree, x, y)
%BIVARIATEPOLYTERMS Get the terms of a bivariate polynomial function of a
% given degree

if size(x, 2) ~= 1
    error('X and Y must be column vectors');
end
if size(x) ~= size(y)
    error('Sizes of ''x'' and ''y'' must be the same');
end

switch degree
    case 0
        terms = ones(size(x)); % Constant
    case 1
        terms = [x y ones(size(x))]; % Linear
    case 2
        terms = [x.*x, y.*y, x.*y, x, y, ones(size(x))]; % Quadratic
    case 3
        terms = [x.*x.*x, y.*y.*y, x.*x.*y, x.*y.*y, x.*x, y.*y, x.*y, x, y, ones(size(x))]; % Cubic
    otherwise
%         error('Polynomial degree not implemented');   
        terms = []; % Smaller than one or not implemented
end
        
    

end

