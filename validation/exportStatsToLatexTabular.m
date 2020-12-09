function exportStatsToLatexTabular(stats, outFile)

methods = {'Nearest', 'Delaunay', 'Natural', 'IDW', 'Kriging', 'MLS', ...
           'RBF.linear', 'RBF.cubic', 'RBF.quintic', 'RBF.multiquadric', 'RBF.thinplate', 'RBF.green', 'RBF.tensionspline', 'RBF.regularizedspline', 'RBF.gaussian', 'RBF.wendland', ...
           'QTPURBF.linear', 'QTPURBF.cubic', 'QTPURBF.quintic', 'QTPURBF.multiquadric', 'QTPURBF.thinplate', 'QTPURBF.green', 'QTPURBF.tensionspline', 'QTPURBF.regularizedspline', 'QTPURBF.gaussian', 'QTPURBF.wendland'};
       
fid = fopen(outFile, 'w');
if fid < 0
    error('Cannot open output file for writing');
end

% Header of the table
fprintf(fid, '\\begin{tabular}{|c|c|c|c|}\n');
fprintf(fid, '\\hline\n');
fprintf(fid, '\\multicolumn{2}{c}{\\textbf{Method}} & \\textbf{Mean Error} & \\textbf{Run Time}\n');
fprintf(fid, '\\hline\n');

% Main content
for i = 1:numel(methods)    
    splMethod = regexp(methods{i}, '\.', 'split');                
    if numel(splMethod) == 1
        % Non-RBF method
        fprintf(fid, '\\multicolumn{2}{c}{%s} & %s & %s\n', splMethod{1}, stats.(splMethod{1}).meanAbsDiff, stats.(splMethod{1}).meanRunTime);
    else
        % RBF method
        fprintf(fid, '%s & %s & %s & %s\n', splMethod{1}, splMethod{2}, stats.(splMethod{1}).(splMethod{2}).meanAbsDiff, stats.(splMethod{1}).(splMethod{2}).meanRunTime);
    end       
    fprintf(fid, '\\hline\n');
end
fprintf(fid, '\\end{tabular}\n');
fclose(fid);