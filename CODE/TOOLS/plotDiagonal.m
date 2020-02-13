

function h = plotDiagonal()

    xLimits = xlim();
    yLimits = ylim();
    
    minLimits = min([xLimits(1), yLimits(1)]);
    maxLimits = max([xLimits(2), yLimits(2)]);
    
    xlim([minLimits maxLimits]);
    ylim([minLimits maxLimits]);
    
    hold on;
    h = plot(xlim, ylim, '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 2);
    uistack(h,'bottom');

end
