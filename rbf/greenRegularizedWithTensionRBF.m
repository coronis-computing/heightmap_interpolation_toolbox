function fx = greenRegularizedWithTensionRBF(r, e)
% Regularized Green spline with tension, as defined in:
% Mitásová, H., Mitás, L., 1993. Interpolation by regularized spline with
% tension: I. Theory and implementation. Mathematical Geology 25
% (6), 641–655.

Ce = 0.5772156649015328606065120900824; % Value of the euler constant. To get it according to your computer precision: vpa(eulergamma);
e = (e^2)/4;
z = r.*r.*e;
fx = -log(z)-expint(z)-Ce;
fx(r==0) = 0; % Fix singularity

% fx = zeros(size(r));
% 	
% x = e .* r .* r;
% z = x;
% 
% fx = log(x) + Ce;
% En = 0.2677737343 +  8.6347608925 .* x;
% Ed = 3.9584869228 + 21.0996530827 .* x;
% x = x.*x;
% En = En + 18.0590169730 * x;
% Ed = Ed + 25.6329561486 * x;
% x = x.*x;
% En = En + 8.5733287401 * x;
% Ed = Ed + 9.5733223454 * x;
% x = x.*x;
% En = En+x;
% Ed = Ed+x;
% fx = fx + (En ./ Ed) ./ (z .* exp(z));
% 
% maskSmall = x <= 1.0;
% if (any(maskSmall(:)))
%     fxS = 0.99999193 .* x;
% 	x = x.*x;
% 	fxS = fxS - 0.24991055 .* x;
% 	x = x.*x;
% 	fxS = fxS + 0.05519968 .* x;
% 	x = x.*x;
% 	fxS = fxS - 0.00976004 .* x;
% 	x = x.*x;
% 	fxS = fxS + 0.00107857 .* x;
%     fx(maskSmall) = fxS(maskSmall);
% end
% fx(r==0) = 0;

end