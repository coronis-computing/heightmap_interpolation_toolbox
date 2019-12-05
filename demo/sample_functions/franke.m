
function fx = franke(x, y)
% Franke's bivariate function from:
% Franke, R. (1979). A critical comparison of some methods for interpolation of scattered data (No. NPS53-79-003). NAVAL POSTGRADUATE SCHOOL MONTEREY CA.

term1 = 0.75 * exp(-(9.*x-2).^2./4 - (9.*y-2).^2./4);
term2 = 0.75 * exp(-(9.*x+1).^2./49 - (9.*y+1)./10);
term3 = 0.5 * exp(-(9.*x-7).^2./4 - (9.*y-3).^2./4);
term4 = -0.2 * exp(-(9.*x-4).^2 - (9.*y-7).^2);

fx = term1 + term2 + term3 + term4;