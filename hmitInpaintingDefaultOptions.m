function options = hmitInpaintingDefaultOptions(method)

options.DebugShowStep = false;
options.DebugVideoFile = '';
options.DebugItersPerFrame = 100;

%% Sobolev inpainter
switch method
    case 'sobolev'
        options.UpdateStepSize = .8/4;
        options.RelChangeTolerance = 1e-5;
        options.MaxIters = 100000;
    case 'tv'        
        options.RelChangeTolerance = 1e-5;
        options.MaxIters = 100000;
        options.Epsilon = 1;
        options.UpdateStepSize = .9*options.Epsilon/4;
    case 'ccst'
        options.UpdateStepSize = 0.01;
        options.RelChangeTolerance = 1e-8;
        options.Relaxation = 1.4;
        options.MaxIters = 1e8;
        options.Tension = 0.3;
        options.GridStepX = 1;
        options.GridStepY = 1;
    case 'amle'
        options.UpdateStepSize = 0.01;
        options.RelChangeTolerance = 1e-7;
        options.MaxIters = 1e8;
        options.GridStepX = 1;
        options.GridStepY = 1;
    case 'bertalmio'
        options.UpdateStepSize = 0.1;
        options.RelChangeTolerance = 1e-5;
        options.MaxIters = 1e8;
        options.RegularizationIters = 15;
        options.AnisotropicDiffusionIters = 2;
        options.GridStepX = 1;
        options.GridStepY = 1;
end