function rbfFun = rbfTypeToFunctor(rbfType, e)

if isa(rbfType, 'function_handle')
    rbfFun = rbfType;
else
    switch lower(rbfType)
        case 'linear'
            rbfFun = @(x) linearRBF(x);
        case 'cubic'
            rbfFun = @(x) cubicRBF(x);
        case 'quintic'
            rbfFun = @(x) quinticRBF(x);                        
        case 'multiquadric'
            rbfFun = @(x) multiQuadricRBF(x, e);
        case 'inversemultiquadric'
            rbfFun = @(x) inverseMultiQuadricRBF(x, e);
        case 'thinplate'
            rbfFun = @(x) thinPlateSplineRBF(x);                
        case 'tensionspline'
            rbfFun = @(x) tensionSplineRBF(x, e);    
        case 'regularizedspline'
            rbfFun = @(x) regularizedSplineRBF(x, e);        
        case 'green'
            rbfFun = @(x) greenRBF(x);                    
        case 'greenwithtension'
            rbfFun = @(x) greenWithTensionRBF(x, e);
        case 'greenregularizedwithtension'
            rbfFun = @(x) greenRegularizedWithTensionRBF(x, e);
        case 'gaussian'
            rbfFun = @(x) gaussianRBF(x, e);                    
        case 'wendland'
            rbfFun = @(x) wendlandCSRBF(x, e);
        otherwise
            error('Unknown RBFType');
    end
end