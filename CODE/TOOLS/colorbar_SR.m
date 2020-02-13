% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function configures a colorbar for spontaneous activity, with limits between
% 0.1 and 100 Hz and log spacing.
% ----------------------------------------------------------------------------------
function colorbar_SR(gca)

    hBar = colorbar();
    set(gca,'CLim',log([0.1 100]))
    ylabel(hBar, 'Spontaneous rate (1/s)', 'Rotation', -90, 'VerticalAlignment', 'bottom', 'FontSize', 11)
    hBar.Ticks = log([0.1 1 10 100]);
    hBar.TickLabels = getLabel([0.1 1 10 100]);

end