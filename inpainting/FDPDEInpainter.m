classdef (Abstract) FDPDEInpainter
    %FDPDEINPAINTER Finite-Differences Partial Differential Equation (FDPDE) Inpainter 
    %   Common interphase for PDE-based inpainting methods. Solves the
    %   problem using finite differences
    
    properties 
        relChangeTolerance = 1e-8; % Relative tolerance, stop the gradient descent when the energy descent between iterations is less than this value
        maxIters = 100000; % Maximum number of gradient descent iterations to perform
        dt = 1e-2; % Gradient descent step size
        relax = 1; % Over-relaxation parameter
        hx = 1; % Grid step size in X
        hy = 1; % Grid step size in Y
        regEachIters = -1; % Number of evolution iterations after which we will regularize the function (if applicable, <= 0 deactivates regularization)
        % Debug options
        debugShowStep = false;
        debugCreateVideo = false;
        debugVideoFile = '';
        debugItersPerFrame = 1000; % Show (or record) a frame every this number of iterations
    end
    
    methods
        function obj = FDPDEInpainter(varargin)
            %FDPDEINPAINTER Construct an instance of this class
            
            p = inputParser;
            p.KeepUnmatched=true; % WARNING: This results in the name of the parameters not being checked exactly!
            validGTZero = @(x) isscalar(x) && x >= 0;
            validGTZeroInt = @(x) isscalar(x) && x >= 0 && floor(x) == x;
            validInt = @(x) isscalar(x) && floor(x) == x;
            validScalarLogical = @(x) isscalar(x) && islogical(x);
            validRelaxation = @(x) isscalar(x) && x >= 1 && x <= 2;
            addParameter(p, 'UpdateStepSize', 1e-2, validGTZero); 
            addParameter(p, 'RelChangeTolerance', 1e-8, validGTZero);            
            addParameter(p, 'MaxIters', 1e8, validGTZeroInt);
            addParameter(p, 'Relaxation', 1, validRelaxation);
            addParameter(p, 'DebugShowStep', false, validScalarLogical);
            addParameter(p, 'DebugVideoFile', '', @ischar);
            addParameter(p, 'DebugItersPerFrame', 1000, validGTZeroInt);
            addParameter(p, 'GridStepX', 1, @isscalar);
            addParameter(p, 'GridStepY', 1, @isscalar);
            addParameter(p, 'RegularizationIters', -1, @isscalar); 
            parse(p, varargin{:});
            
            obj.relChangeTolerance = p.Results.RelChangeTolerance;              
            obj.maxIters = p.Results.MaxIters;  
            obj.dt = p.Results.UpdateStepSize;                        
            obj.hx = p.Results.GridStepX;
            obj.hy = p.Results.GridStepY;
            obj.regEachIters = p.Results.RegularizationIters;
            
            obj.debugShowStep = p.Results.DebugShowStep;
            obj.debugItersPerFrame = p.Results.DebugItersPerFrame;
            if ~isempty(p.Results.DebugVideoFile)
                obj.debugVideoFile = p.Results.DebugVideoFile;
                obj.debugCreateVideo = true;
            end            
        end
        
        function inpaitedImage = inpaint(obj, image, mask)
            %INPAINT Inpainting of an "image" by iterative minimization of
            %   a PDE functional
            %
            % Input:
            %   img: input image to be inpainted
            %   mask: logical mask of the same size as the input image. 1 == known pixels, 0 == unknown pixels to be
            %         inpainted
            % Output:
            %   f: inpainted image
            
            % Get the number of channels in the image
            [sy, sx, channels] = size(image);
            if size(mask, 1) ~= sy || size(mask, 2) ~= sx
                error('The mask must have the first two dimensions equal to those of the image');
            end
            
            inpaitedImage = zeros(size(image));
            
            % Initialize the debug video?
            if obj.debugCreateVideo
                % Create the output video
               video = VideoWriter(obj.debugVideoFile, 'Motion JPEG AVI');
               video.Quality = 100;
               open(video);               
            end
            
            % Perform inpainting on each channel            
            for c = 1:channels                     
                % Slice the current channel
                f = image(:, :, c);
                Pi = @(f)f.*(1-mask) + image(:, :, c).*mask;
                
                % Perform pre-processing?
                [f, mask, obj] = preProcess(obj, f, mask);
                
                % Gradient descent
                for i=1:obj.maxIters
                    % Perform a step in the optimization                
                    fnew = Pi(f + obj.dt*obj.stepFun(f)); % Minus because we assume stepFun to return the gradient, and we want to move against the gradient. Take it into account when defining a stepFun!

                    % Over-relaxation?                
                    if obj.relax > 1
                        fnew = Pi(f*(1-obj.relax) + fnew*obj.relax);
                    end                    
                    
                    % Compute the difference with the previous step
                    diff = norm(fnew(:)-f(:))/norm(fnew(:));

                    % Update the function
                    f = fnew;

                    % Debug output (if required)
                    if (obj.debugShowStep || obj.debugCreateVideo) && mod(i-1, obj.debugItersPerFrame) == 0
                        imagesc(f); 
                        if obj.debugCreateVideo
                            frame = getframe(gca);
                            writeVideo(video, frame);
                        end
                    end

                    % Stop if "almost" no change
                    if diff < obj.relChangeTolerance
                        break;
                    end
                    
                    % Regularize?
                    if obj.regEachIters > 0 && mod(i, obj.regEachIters) == 0
                        [f, mask, obj] = regularization(obj, f, mask);
                    end
                end

                % Issue a warning if the maximum number of iterations has been
                % reached (normally means that the solution will not be
                % useful because it did not converge...)
                if i == obj.maxIters
                    warning('Maximum number of iterations reached');
                end
                
                % Perform post-processing?
                [f, mask, obj] = postProcess(obj, f, mask);
                
                inpaitedImage(:, :, c) = f;
            end
            
            % Close the debug video?
            if obj.debugCreateVideo, close(video); end
        end
                
        function varargin = removeParentParametersFromVarargin(obj, varargin)
            paramsToDelete = {'UpdateStepSize', 'RelChangeTolerance', 'MaxIters', 'Relaxation', 'DebugShowStep', 'DebugVideoFile', 'DebugItersPerFrame', 'GridStepX', 'GridStepY', 'RegularizationIters'};
            varargin = deleteParamsFromVarargin(paramsToDelete, varargin);
        end
    end
    
    % The methods that need to be implemented by subclasses
    methods (Abstract) 
        f = stepFun(obj, f, mask);
    end
    
    % Optional methods that can be redefined, if some method needs them
    methods (Access = protected)
        function [f, mask, obj] = preProcess(obj, f, mask)
            % Pre-processing to be executed prior to the gradient descent
        end
        function [f, mask, obj] = regularization(obj, f, mask)
         	% Regularization to be executed after a user-defined number of
         	% gradient descent steps
        end
        function [f, mask, obj] = postProcess(obj, f, mask)
            % Post-processing to be executed after the gradient descent
        end
   end
end

