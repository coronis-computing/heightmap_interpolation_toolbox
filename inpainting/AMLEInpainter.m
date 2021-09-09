classdef AMLEInpainter < FDPDEInpainter
    %AMLEINPAINTER Absolutely Minimizing Lipschitz Extension (AMLE) Inpainter
    % Implements the method in:
    %   Andrés Almansa, Frédéric Cao, Yann Gousseau, and Bernard Rougé.
    %   Interpolation of Digital Elevation Models Using AMLE and Related
    %   Methods. IEEE TRANSACTIONS ON GEOSCIENCE AND REMOTE SENSING, VOL. 40, 
    %   NO. 2, FEBRUARY 2002
    % 
    
    properties        
        Kfx;
        Kfy;
        Kbx;
        Kby;
        Kcx;
        Kcy;
    end
    
    methods
        function obj = AMLEInpainter(varargin)
            obj@FDPDEInpainter(varargin{:});
            
            % Constructor
            varargin = obj.removeParentParametersFromVarargin(varargin{:});
            
            p = inputParser;
            parse(p, varargin{:});
            
            % Compute the stencils
            [obj.Kfx, obj.Kfy] = forwardDifferenceKernels(obj.hx, obj.hy);
            [obj.Kbx, obj.Kby] = backwardDifferenceKernels(obj.hx, obj.hy);
            [obj.Kcx, obj.Kcy] = centeredDifferenceKernels(obj.hx, obj.hy);
        end
        
        function f = stepFun(obj, f, mask)
            % First derivatives X/Y
            ux = conv2(f, obj.Kfx, 'same');
            uy = conv2(f, obj.Kfy, 'same');
        
            % Second derivatives
            uxx = conv2(ux, obj.Kbx, 'same');
            uxy = conv2(ux, obj.Kby, 'same');
            uyx = conv2(uy, obj.Kbx, 'same');
            uyy = conv2(uy, obj.Kby, 'same');
    
            % Du/|Du| with central differences
            v(:, :, 1) = conv2(f, obj.Kcx, 'same');
            v(:, :, 2) = conv2(f, obj.Kcy, 'same');
            
            % Normalize the direction field
            dennormal = sqrt(sum(v.^2, 3) + 1e-15);
            v(:, :, 1) = v(:, :, 1)./dennormal;
            v(:, :, 2) = v(:, :, 2)./dennormal;
    
            % CORE ITERATION
%             f = -1*(uxx.*v(:, :, 1).^2 + uyy.*v(:, :, 2).^2 + (uxy+uyx).*(v(:,:,1).*v(:,:,2)));
            
            f = -1*(uxx.*v(:,:,1).^2 + uyy.*v(:,:,2).^2 + (uxy+uyx).*(v(:,:, 1).*v(:,:, 2)));
        end        
    end
end

