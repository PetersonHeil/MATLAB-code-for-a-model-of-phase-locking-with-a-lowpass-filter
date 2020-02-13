% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function configures a colorbar for frequency, with limits between
% 200 and 5000 Hz and log spacing.
% ----------------------------------------------------------------------------------
function colorbar_f1(gca)

    set(gca,'CLim',log([200 5000]))
    hBar = colorbar();
    ylabel(hBar, 'f1 (kHz)', 'Rotation', -90, 'VerticalAlignment', 'bottom', 'FontSize', 11)
    hBar.Ticks = log([200 300 400 500 600 700 800 900 1000 2000 3000 4000 5000]);
    hBar.TickLabels = {'0.2' '' '' '' '' '' '' '' '1' '' '' '' '5'};
    
end