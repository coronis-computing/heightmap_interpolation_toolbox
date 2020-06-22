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
    end
    
    methods
        function obj = BertalmioInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});
            
            % Compute the stencils
            obj.laplacianStencil = laplacian5PointsStencil(obj.hx, obj.hy);
            [obj.Kfx, obj.Kfy] = forwardDifferenceKernels(obj.hx, obj.hy);
            [obj.Kbx, obj.Kby] = backwardDifferenceKernels(obj.hx, obj.hy);
            obj.Kxx = obj.Kix - obj.Kbx;
            obj.Kyy = obj.Kiy - obj.Kby;
            [obj.Kcx, obj.Kcy] = centeredDifferenceKernels(obj.hx, obj.hy);
        end
        
        function f = stepFun(obj, f, mask)            
            % First derivatives X/Y (gradient)
            ux = conv2(f, obj.Kfx, 'same');
            uy = conv2(f, obj.Kfy, 'same');
            
            % Normal field: perpendicular to gradient
            uxn = uy;
            uyn = -1*ux;
%             uxn = -1*uy;
%             uyn = ux;   
            
            % And the gradient of the Laplacian
            laplacian = conv2(f, obj.laplacianStencil, 'same');
            lux = conv2(laplacian, obj.Kfx, 'same');
            luy = conv2(laplacian, obj.Kfy, 'same');
            
            % Normalize the direction fields
            normFactor = sqrt(uxn.^2 + uyn.^2 + 1e-15);
            uxn = uxn./normFactor;
            uyn = uyn./normFactor;
            normFactor = sqrt(lux.^2 + luy.^2 + 1e-15);
            lux = lux./normFactor;
            luy = luy./normFactor;
            
            f = -1.*((uxn.*lux) + (uyn.*luy));
        end
        
        
        function u = anisotropicDiffusion(obj, u, dt, numIters, eps, geps) 
            ux  = conv2(u, obj.Kcx, 'same');
            uy  = conv2(u, obj.Kcy, 'same');
            uxx = conv2(u, obj.Kxx, 'same');
            uyy = conv2(u, obj.Kyy, 'same');
            uxy = conv2(ux, obj.Kcy, 'same');
                
            for i=1:numIters
                sqNormGradient = ux.^2 + uy.^2 + eps;                
                u = u + dt*geps*(uyy .* (ux.^2) + uxx .* (uy.^2) - 2.*ux.*uy.*uxy) / sqNormGradient;
            end
        end
    end
end

