function v = structToVarargin(s)

fields = fieldnames(s);
v = {};
ind = 1;
for i = 1:numel(fields)
    v{ind} = fields{i};
    ind = ind+1;
    v{ind} = s.(fields{i});
    ind = ind+1;
end
