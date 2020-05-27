function epsilon = scaleEpsilonAccordingToRbfType(rbfType, epsilon, x, y, z)
%preProcessIfNeeded Some RBF types require working on scaled
%    data and/or scaled parameters, this is the function where
%    these special cases are handled

if strcmpi(rbfType, 'greenwithtension') || strcmpi(rbfType, 'greenregularizedwithtension')
    % greenWithTensionRBF expects the epsilon (tension parameter) to be between 0..1
    if epsilon < 0 || epsilon >= 1
        error('greenWithTensionRBF expects the tension parameter (epsilon) to be 0 <= epsilon < 1!');
    end
    
    % Length scale
    % DevNote: This parameter (\alpha in the original reference) is an
    % heuristic, and in GMT is computed from the range of values in of the
    % QUERY points, so if you are using this formula with the data points 
    % that is a different approximation!
    IM = sqrt (-1);
    lengthScale = 50/abs(max(x(:)) - min(x(:)) + IM * (max(y(:)) - min(y(:))));
    
    % With the following transformation, epsilon changes to be the
    % parameter 'p' in the original reference (Wessel and Bercovici, 1998)
    epsilon = sqrt(epsilon/(1-epsilon));
    epsilon = epsilon*lengthScale;
end

end