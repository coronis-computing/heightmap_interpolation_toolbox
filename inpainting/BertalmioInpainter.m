classdef BertalmioInpainter < FDPDEInpainter
    % Bertalmio et al. Inpainter, implementation of the method presented in:
    %     Marcelo Bertalmio, Guillermo Sapiro, Vincent Caselles, and Coloma Ballester. 2000. Image inpainting. In Proceedings of the 27th annual conference on Computer graphics and interactive techniques (SIGGRAPH ’00). ACM Press/Addison-Wesley Publishing Co., USA, 417–424. DOI:https://doi.org/10.1145/344779.344972
    
    properties
        laplacianStencil; % Laplacian stencil
        Kfx; % Forward differences in X kernel 
        Kfy; % Forward differences in Y kernel
        Kbx; % Backward differences in X kernel
        Kby; % Backward differences in Y kernel
        Kxx; % Forward - Backward differences in X kernel
        Kyy; % Forward - Backward differences in Y kernel
        Kcx; % Centered differences in X kernel
        Kcy; % Centered differences in Y kernel
        curIter; % Internal counter for number of iterations
        gepsRadius; % Radius of the structuring element (circle) used to create the lambda_eps band from the inpainting domain
        gepsLinearDiffusionIters; % Number of linear diffusion iterations to be applied in order to interpolate the values inside the lambda_eps band
        anisotropicDiffusionIters; % Number of anisotropic diffusion iterations to apply both at the preProcessing and regularization steps
        geps; % The g_epsilon band from (see original reference)
    end
    
    methods
        function obj = BertalmioInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});
            
            varargin = obj.removeParentParametersFromVarargin(varargin{:});
            
            p = inputParser;
            validGTZero = @(x) isscalar(x) && x >= 0;
            addParameter(p, 'GEpsilonStripRadius', 6, validGTZero);
            addParameter(p, 'GEpsilonLinearDiffusionIters', 5, validGTZero);
            addParameter(p, 'AnisotropicDiffusionIters', 3, validGTZero);
            parse(p, varargin{:});
            
            obj.gepsRadius = p.Results.GEpsilonStripRadius;
            obj.gepsLinearDiffusionIters = p.Results.GEpsilonLinearDiffusionIters;
            obj.anisotropicDiffusionIters = p.Results.AnisotropicDiffusionIters;
            
            % Compute the stencils
            obj.laplacianStencil = laplacian5PointsStencil(obj.hx, obj.hy);
            [obj.Kfx, obj.Kfy] = forwardDifferenceKernels(obj.hx, obj.hy);
            [obj.Kbx, obj.Kby] = backwardDifferenceKernels(obj.hx, obj.hy);
            obj.Kxx = obj.Kfx - obj.Kbx;
            obj.Kyy = obj.Kfy - obj.Kby;
            [obj.Kcx, obj.Kcy] = centeredDifferenceKernels(obj.hx, obj.hy);
        end
        
        function obj = computeGEpsilon(obj, mask)
            
            zs = zeros(size(mask));
            maskeps = 1-mask;
            obj.geps = maskeps;
            
            % Structuring element for creating the boundary area
            % \lambda_epsilon
            % from the original reference
            se = strel('ball', obj.gepsRadius, 0, 0);
            lambdaeps = imdilate(maskeps, se)-maskeps;
            
            % Interpolate g_epsilon with linear diffusion (harmonic
            % inpainting)
            for i = 1:obj.gepsLinearDiffusionIters
                lapGeps = div(grad(obj.geps));
                obj.geps = obj.geps + obj.dt*lapGeps + lambdaeps*(maskeps-obj.geps);
            end
        end
        
        function f = stepFun(obj, f, mask)            
            % First derivatives X/Y (gradient)
            ux = conv2(f, obj.Kcx, 'same');
            uy = conv2(f, obj.Kcy, 'same');
            
            % Normal field: perpendicular to gradient
            uxn = -1*uy;
            uyn = ux;   
            
            % Normalize the normal field
            normFactor = sqrt(uxn.^2 + uyn.^2 + 1e-15);
            uxn = uxn./normFactor;
            uyn = uyn./normFactor;
            
            % Gradient of the Laplacian
            laplacian = conv2(f, obj.laplacianStencil, 'same');
            lux = conv2(laplacian, obj.Kcx, 'same');
            luy = conv2(laplacian, obj.Kcy, 'same');

            % Gradients of the image (forward and backward differences)
            uxf = conv2(f, obj.Kfx, 'same');
            uxb = conv2(f, obj.Kbx, 'same');
            uyf = conv2(f, obj.Kfy, 'same');
            uyb = conv2(f, obj.Kby, 'same');
                                   
            % Beta function in the paper (project the gradient of the 
            % laplacian into the normalized normal field)
            beta = ((uxn.*lux) + (uyn.*luy));
            
            zs = zeros(size(f));
            slopeLimitedGradientBetaPos = sqrt(min(uxb, zs).^2 + max(uxf, zs).^2 + min(uyb, zs).^2 + max(uyf, zs).^2);
            slopeLimitedGradientBetaNeg = sqrt(max(uxb, zs).^2 + min(uxf, zs).^2 + max(uyb, zs).^2 + min(uyf, zs).^2);
            
            slopeLimitedGradient = (beta > 0).*slopeLimitedGradientBetaPos + (beta <= 0).*slopeLimitedGradientBetaNeg;
            
            f = beta.*slopeLimitedGradient;            
        end
        
        
        function u = anisotropicDiffusion(obj, u, dt, numIters, eps, geps) 
            ux  = conv2(u, obj.Kcx, 'same');
            uy  = conv2(u, obj.Kcy, 'same');
            uxx = conv2(u, obj.Kxx, 'same');
            uyy = conv2(u, obj.Kyy, 'same');
            uxy = conv2(ux, obj.Kcy, 'same');
                
            for i=1:numIters
                sqNormGradient = ux.^2 + uy.^2 + eps;                
                u = u + dt*geps.*(uyy .* (ux.^2) + uxx .* (uy.^2) - 2.*ux.*uy.*uxy) ./ sqNormGradient;
            end
        end
    end
    
    methods (Access = protected)
        function [f, mask, obj] = preProcess(obj, f, mask)
            % Pre-processing to be executed prior to the gradient descent
            obj = obj.computeGEpsilon(mask);
            f = obj.anisotropicDiffusion(f, obj.dt, 1, 1e-7, obj.geps);
        end        
        function [f, mask, obj] = regularization(obj, f, mask)
         	% Regularization to be executed after a user-defined number of
         	% gradient descent steps
            f = obj.anisotropicDiffusion(f, obj.dt, obj.anisotropicDiffusionIters, 1e-7, obj.geps);
        end
    end
end

