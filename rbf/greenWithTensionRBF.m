function fx = greenWithTensionRBF(r, e)
%% Green's RBF with tension as defined by Wessel and Bercovici in:
% 
% Wessel, P., Bercovici, D., 1998. Interpolation with splines in tension: a
% Green’s function approach. Mathematical Geology 30 (1), 77–93.
% 
% When tension (e) == 0, defaults to greenRBF(r)
% 

if e == 0
    % Regular Green function
    fx = (r.^2) .* (log(r)-1);
else
    % Green function with tension
    g0 = 0.115931515658412420677337; % log(2) - 0.5772156...
    fx = besselk(0, e*r)+log(e*r)-g0;    
end
fx(r==0) = 0; % Fix singularity of Green's function at 0

end

