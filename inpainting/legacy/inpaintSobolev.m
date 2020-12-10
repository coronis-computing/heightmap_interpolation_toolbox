function imgInpainted = inpaintSobolev(img, mask, relTolerance, maxIters, outDemoVideo)
%SOBOLEV Inpainting of an "image" by iterative minimization of the Sobolev
%   norm
%
% Input:
%   img: input image to be inpainted
%   mask: logical mask of the same size as the input image. 1 == known pixels, 0 == unknown pixels to be
%         inpainted
%   relTolerance: relative tolerance, stop the gradient descent when the energy descent between iterations is less than this value
%   numIters: maximum number of gradient descent iterations to perform (default = 100000)

% Input parameters check
if nargin < 3 || isempty(relTolerance)
    relTolerance = 1e-5;
end
if nargin < 4 || isempty(maxIters)
    maxIters = 100000;
end
createDemoVideo = false;
if nargin > 4 && ~isempty(outDemoVideo)
   % Create the output video
   createDemoVideo = true;
   video = VideoWriter(outDemoVideo,'Motion JPEG AVI');
   video.Quality = 100;
   open(video);
   itersPerFrame = 10;
end

% Functors
Pi = @(f)f.*(1-mask) + img.*mask;
Delta = @(x)div(grad(x));
norm1 = @(f)norm(f(:));

% Gradient descent step size
tau = .8/4;

% Gradient descent iterations
imgInpainted = img;
energyPrev = 0;
for i=1:maxIters
    energy = norm1(grad(imgInpainted));        
    imgInpainted = Pi( imgInpainted + tau*Delta(imgInpainted) );
    
    if abs(energy-energyPrev) < relTolerance
        break;
    end
    energyPrev = energy;
    
    % Save a frame of the video
    if createDemoVideo && mod(i-1, itersPerFrame) == 0
        imagesc(imgInpainted'); axis xy; colorbar;
        frame = getframe(gcf);        
        writeVideo(video, frame);
    end
end

if i == maxIters
    warning('Maximum number of iterations reached');
end

if createDemoVideo, close(video); end

end
