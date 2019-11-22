function fx = thinPlateSplineRBF(r)

if r == 0
    fx = 0;
else
    fx = r.^2*log(r);
end

end

