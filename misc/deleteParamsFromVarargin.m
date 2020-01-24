function vars = deleteParamsFromVarargin(paramsToDelete, vars)
%Utility function to delete parameter keys and values from a varargin input
% Useful when using the same varargin in a base class to initialize a
% derived class
% 
% INPUT:
%   - paramsToDelete: a cell array with the keys (char arrays) of the
%   parameters to delete from the varargin array.
%   - varargin
% 
% OUTPUT:
%   - varargin: filtered varargin array.

for i = 1:numel(paramsToDelete)
    ind = find(strcmpi(vars, paramsToDelete{i}));
    if ~isempty(ind)
        vars(ind+1) = []; % The value
        vars(ind) = []; % The parameter string
    end
end        

end

