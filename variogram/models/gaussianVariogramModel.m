function g = gaussianVariogramModel(h, a, c1, c0)
%gaussianVariogramModel Gaussian model for variogram fitting
%   Reference: http://www.supergeotek.com/Spatial_Statistical_ENG_HTML/gaussian_model.htm

g = c0+c1*(1-exp(-(h.^2)/(a^2)));

end

