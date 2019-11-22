function fx = multiQuadricRBF(r, e)
%MULTIQUADRICRBF MultiQuadric Radial Basis Function

fx = sqrt(r.^2 + e.^2);

end

