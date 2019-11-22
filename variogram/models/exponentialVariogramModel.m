function g = exponentialVariogramModel(h, a, c1, c0)
%exponentialVariogramModel Exponential model for variogram fitting 
%  Reference: http://www.supergeotek.com/Spatial_Statistical_ENG_HTML/exponential_model.htm

g = c0+c1*(1-exp(-h./a));

end

