% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function converts dB SPL to stimulus amplitude in pascals
% ----------------------------------------------------------------------------------
function pascals = db2pa(decibels)
    pascals = 20e-6.*sqrt(2).*10.^(decibels./20);
end