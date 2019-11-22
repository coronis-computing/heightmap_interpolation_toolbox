function fx = gaussianRBF(r, e)
%GAUSSIANRBF Summary of this function goes here
%   Detailed explanation goes here

fx = exp(-(e*r.^2));

end

