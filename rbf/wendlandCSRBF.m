function fx = wendlandCSRBF(r, e)
%WENDLANDCSRBF Summary of this function goes here
%   e: support of the function

% fx = 1-((max(1-r./e, 0).^4).*(1+4*r./e));
fx = ((max(1-r./e, 0).^4).*(1+4*r./e));

end

