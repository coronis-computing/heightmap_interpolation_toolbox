function g = sphericalVariogramModel(h, a, c1, c0)
%sphericalVariogramModel Spherical model for variogram fitting
%   Reference: http://www.supergeotek.com/Spatial_Statistical_ENG_HTML/spherical_mode.htm

g = zeros(size(h));
ind = h <= a;
g(ind) = c0 + c1*((3*h(ind)./(2*a))-1/2*(h(ind)./a).^3);
g(~ind) = c0 + c1;

end

