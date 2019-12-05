function fx = thinPlateSplineRBF(r)

fx = r.^2.*log(r);
fx(r==0) = 0;

end

