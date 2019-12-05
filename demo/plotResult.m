function plotResult(x, y, z, xi, yi, zi, spRows, spCols, spInd, titleStr, xLabel, yLabel, zLabel, setAxisEqual)
%plotResult Simple helper function to draw results in the demos
    subplot(spRows, spCols, spInd);
    if ~isempty(xi)
        surf(xi, yi, zi);
    end
    hold on;
	if ~isempty(x)
        plot3(x, y, z, '.r');
    end    
    title(titleStr);
    xlabel(xLabel);
    ylabel(yLabel);
    zlabel(zLabel);
    if setAxisEqual
        axis equal;
    end
    hold off;
end