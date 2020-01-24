function fx = flower(x, y)
%FLOWER Flower-shaped function
%   Flower-shaped function found in the following example from scipy docs:
%   https://scipython.com/book/chapter-8-scipy/examples/two-dimensional-interpolation-with-scipyinterpolategriddata/
% 
    s = hypot(x, y);
    phi = atan2(y, x);
    tau = s + s.*(1-s)./5 .* sin(6.*phi);
    fx = 5.*(1-tau) + tau;
end

