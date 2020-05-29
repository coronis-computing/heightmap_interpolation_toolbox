classdef (Abstract) FDPDEInpainter
    %FDPDEINPAINTER Finite-Differences Partial Differential Equation (FDPDE) Inpainter 
    %   Common interphase for PDE-based inpainting methods. Solves the
    %   problem using finite differences
    
    properties
        relChangeTolerance = 1e-8; % Relative tolerance, stop the gradient descent when the energy descent between iterations is less than this value
        maxIters = 100000; % Maximum number of gradient descent iterations to perform
        dt = 1e-2; % Gradient descent step size
        relax = 1; % Over-relaxation parameter
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
            validScalarLogical = @(x) isscalar(x) && islogical(x);
            validRelaxation = @(x) isscalar(x) && x >= 1 && x <= 2;
            addParameter(p, 'UpdateStepSize', 1e-2, validGTZero); 
            addParameter(p, 'RelChangeTolerance', 1e-8, validGTZero);            
            addParameter(p, 'MaxIters', 1e8, validGTZeroInt);
            addParameter(p, 'Relaxation', 1, validRelaxation);
            addParameter(p, 'DebugShowStep', false, validScalarLogical);
            addParameter(p, 'DebugVideoFile', '', @ischar);
            addParameter(p, 'DebugItersPerFrame', 1000, validGTZeroInt);            
            parse(p, varargin{:});
            
            obj.relChangeTolerance = p.Results.RelChangeTolerance;              
            obj.maxIters = p.Results.MaxIters;  
            obj.dt = p.Results.UpdateStepSize;
            obj.debugShowStep = p.Results.DebugShowStep;
            obj.debugItersPerFrame = p.Results.DebugItersPerFrame;
            if ~isempty(p.Results.DebugVideoFile)
                obj.debugVideoFile = p.Results.DebugVideoFile;
                obj.debugCreateVideo = true;
            end            
        end
        
        function f = inpaint(obj, image, mask)
            %INPAINT Inpainting of an "image" by iterative minimization of
            %   a PDE functional
            %
            % Input:
            %   img: input image to be inpainted
            %   mask: logical mask of the same size as the input image. 1 == known pixels, 0 == unknown pixels to be
            %         inpainted
            % Output:
            %   f: inpainted image
            
            Pi = @(f)f.*(1-mask) + image.*mask;
            
            % Initialize
            f = image;
            
            % Initialize the debug video?
            if obj.debugCreateVideo
                % Create the output video
               video = VideoWriter(obj.debugOutputVideoFile, 'Motion JPEG AVI');
               video.Quality = 100;
               open(video);               
            end
            
            % Gradient descent
            for i=1:obj.maxIters
                % Perform a step in the optimization                
                fnew = Pi(f - obj.dt*obj.stepFun(f)); % Minus because we assume stepFun to return the gradient, and we want to move against the gradient. Take it into account when defining a stepFun!
                
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
                    imagesc(f'); axis xy; colorbar;
                    if obj.createDemoVideo
                        frame = getframe(gcf);        
                        writeVideo(video, frame);
                    end
                end
                
                % Stop if "almost" no change
                if diff < obj.relChangeTolerance
                    break;
                end
            end
            
            % Issue a warning if the maximum number of iterations has been
            % reached (normally means that the solution will not be
            % useful because it did not converge...)
            if i == obj.maxIters
                warning('Maximum number of iterations reached');
            end
            
            % Close the debug video?
            if obj.debugCreateVideo, close(video); end
        end
                
        function varargin = removeParentParametersFromVarargin(obj, varargin)
            paramsToDelete = {'UpdateStepSize', 'RelChangeTolerance', 'MaxIters', 'DebugShowStep', 'DebugVideoFile', 'DebugItersPerFrame'};
            varargin = deleteParamsFromVarargin(paramsToDelete, varargin);
        end
    end
    
    methods (Abstract) 
        f = stepFun(obj, f, mask);
    end
end

