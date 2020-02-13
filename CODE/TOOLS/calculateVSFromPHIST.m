% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% Function that computes vector strength from a period histogram
% ----------------------------------------------------------------------------------
function [VS, meanPhase] = calculateVSFromPHIST(PHIST, varargin)
    vars.omitRightBin = false;
    vars = updateVars(vars,varargin);

    if vars.omitRightBin
        phases = linspace(0, 2*pi, numel(PHIST)+1);
        phases(end) = [];
    else
        phases = linspace(0, 2*pi, numel(PHIST));
    end

    % Make sure that the histogram values are valid
    if any(isnan(PHIST))
        error('ERROR: PHIST contains NaN values')
    end

    % Rescale the histogram so that the mean height is 100 (this helps avoid 
    % underflow or overflow errors, but doesn't change VS or theta!)
    if max(PHIST) < 1
        PHIST = PHIST.*(100/max(PHIST));
    end

    % Calculate vector strength
    VS = 1/sum(PHIST) * sqrt(sum(PHIST.*cos(phases))^2 + sum(PHIST.*sin(phases))^2);

    % Using ATAN2 automatically adjusts the result based on the signs of X
    % and Y. Note that the standard ATAN function takes a single input
    % argument, ATAN(Y/X), but ATAN2 takes the min separately, ATAN2(Y,X).
    meanPhase = atan2(sum(PHIST.*sin(phases)), sum(PHIST.*cos(phases)));

    % Adjust so value lies between 0-2pi
    meanPhase = rem(2*pi+meanPhase, 2*pi);

end