% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function updates the grid titles and color scaling and adds a colorbar.
% ----------------------------------------------------------------------------------
function PLOT_updateGrids(sub, LO_out, HI_out)

    % Update title on "LO" grid
    sub.select(1,1);
    h = gca;
    if LO_out.fit.error < HI_out.fit.error
        title([h.Title.String ' (LO) ' LO_out.vars.errorToMinimize ' = ' num2str(decround(LO_out.fit.error,0.001)) ' (BETTER)'])
    else
        title([h.Title.String ' (LO) ' LO_out.vars.errorToMinimize ' = ' num2str(decround(LO_out.fit.error,0.001))])
    end
    
    % Update title on "HI" grid
    sub.select(1,2);
    h = gca;
    if LO_out.fit.error > HI_out.fit.error
        title([h.Title.String ' (HI) ' HI_out.vars.errorToMinimize ' = ' num2str(decround(HI_out.fit.error,0.001)) ' (BETTER)'])
    else
        title([h.Title.String ' (HI) ' HI_out.vars.errorToMinimize ' = ' num2str(decround(HI_out.fit.error,0.001))])
    end

    % Harmonize color scale across both panels
    overall_min_error = min(LO_out.fit.error, HI_out.fit.error);
    CLim = [1 1.5] .* overall_min_error;
    sub.select(1,1);
    set(gca,'CLim', CLim)
    sub.select(1,2);
    set(gca,'CLim', CLim)

    % Add colorbar
    set(gca,'CLim', CLim)
    colormap(parula)
    h = colorbar;
    
    subplotter.placelegendEastOfPlot(h,100);
    
    CTickLabels = 1:0.05:1.5;
    CTicks = CTickLabels .* overall_min_error;
    set(h,'YTick', CTicks, 'YTickLabel', CTickLabels)
    set(gca,'FontSize', 12)
    ylabel(h, 'Relative NLOGL', 'Rotation', -90, 'VerticalAlignment', 'bottom')
    
end