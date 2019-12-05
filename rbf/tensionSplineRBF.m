function fx = tensionSplineRBF(r, e)
%SPLINEWITHTENSIONRBF Spline with tension.
% Definition of the spline with tension from [2]. You can also find a brief description of its behaviour in [1].
% Note that [1] suggests using a polynomial of degree 0 with this RBF.
% 
% INPUT:
%   - r: value to evaluate.
%   - e: tension parameter.
% 
% OUTPUT:
%   - fx: value of the RBF at r.
% 
% References: 
%  [1] https://pro.arcgis.com/en/pro-app/tool-reference/spatial-analyst/how-spline-works.htm
%  [2] Mitas, L., and H. Mitasova. 1988. General Variational Approach to the Interpolation Problem. Comput. Math. Applic. Vol. 16. No. 12. pp. 983–992. Great Britain.

Ce = 0.5772156649015328606065120900824; % Value of the euler constant. To get it according to your computer precision: vpa(eulergamma);
fx = -(1/(2*pi*e*e))*(log(r.*e./2)+Ce+besselk(0, r.*e));
fx(r==0) = 0; % Singularity at r == 0

end

