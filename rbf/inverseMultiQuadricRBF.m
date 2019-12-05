function fx = inverseMultiQuadricRBF(r, e)

mq = multiQuadricRBF(r, e);
fx = 1./mq;
fx(mq==0) = 0;

end

