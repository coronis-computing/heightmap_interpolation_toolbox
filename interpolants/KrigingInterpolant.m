classdef KrigingInterpolant < RBFInterpolant
    %KRIGING Kriging interpolation method. Note that Kriging is just a
    %  variant of a RBF interpolator where the RBF is a Variogram.
    %  We can obtain Ordinary and Universal Kriging depending on the
    %  'PolynomialDegree' parameter:
    %       - KrigingInterpolant(..., 'PolynomialDegree', 0): Ordinary Kriging
    %       - KrigingInterpolant(..., 'PolynomialDegree', >0): Universal Kriging
    
    properties
        % No properties required for this function other than those on
        % RBFInterpolant
    end
    
    methods
        function obj = KrigingInterpolant(x, y, z, variogram, varargin)
            %KRIGING Construct an instance of this class
            
            if ~isa(variogram, 'Variogram')
                error('The ''variogram'' argument needs to be an instance of the class Variogram');
            end
            
            % Superclass constructor
            obj@RBFInterpolant(x, y, z, varargin{:});
            
            % Set the RBF to be the variogram (note that this overrides the
            % definition of 'RBF' parameter in the original RBFInterpolant
            % constructor)
            obj.rbfFun = @variogram.eval;
        end        
    end
end

