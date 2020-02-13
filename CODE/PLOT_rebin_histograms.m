% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function smooths histograms by rebinning them with a smaller number of bins. 
% This should generally be used only for display purposes, because the rightmost bin 
% will likely contain fewer of the original bins than do the other bins.
% ----------------------------------------------------------------------------------
function Revent_rebinned = PLOT_rebin_histograms(Y, nRebins)

        nPressures = size(Y,1);
        nPoints = size(Y,2);
        nPointsPerRebin = floor(nPoints/nRebins);
        nRemain = rem(nPoints,nPointsPerRebin);
        nPointsPerRebin = repmat(nPointsPerRebin, 1, nRebins);
        nPointsPerRebin(end) = nPointsPerRebin(end) + nRemain;

        iStart = [1 cumsum(nPointsPerRebin(1:end-1))+1];
        iEnd = cumsum(nPointsPerRebin);

        Revent_rebinned = nan(nPressures, nRebins);
        for iCond = 1:nPressures
            for iRebin = 1:nRebins
                Revent_rebinned(iCond,iRebin) = mean(Y(iCond, iStart(iRebin):iEnd(iRebin)));
            end
        end

end
