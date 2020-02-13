% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function converts stimulus amplitude in pascals to dB SPL
% ----------------------------------------------------------------------------------
function decibels = pa2db(pascals)
    decibels = 20*log(pascals/(20e-6*sqrt(2)))/log(10);
end