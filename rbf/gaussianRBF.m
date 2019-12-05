function fx = gaussianRBF(r, e)
%GAUSSIANRBF Summary of this function goes here
%   Detailed explanation goes here

% fx = 1-exp(-(r/e).*2);
fx = exp(-(r/e).^2);
% fx = exp ( - 0.5 * r.^2 / e^2 );

end
