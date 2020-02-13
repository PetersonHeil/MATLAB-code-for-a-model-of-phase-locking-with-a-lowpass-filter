% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function constructs the title for the fit results of a level series
% ----------------------------------------------------------------------------------
function runTitle = PLOT_getRunTitle(out)

    if isfield(out,'data')
        runTitle = {
            [out.data.runName, ', SR=', num2str(decround(out.data.RspontSpike, 0.001)), ' spikes/s, Rspont=', num2str(decround(out.vars.RspontEvent, 0.001)), ' events/s, fc=', num2str(decround(out.vars.fc,0.1)), ', f1=', num2str(decround(out.data.f1,0.1)), ', fc/f1=', num2str(decround(out.vars.fc/out.data.f1,0.1))]
            ['LPForder=' num2str(out.vars.order) , ', M0=', num2str(out.vars.M0), ', b=', num2str(out.vars.b), ', D=', num2str(out.vars.D)]
            [out.vars.errorToMinimize '=', num2str(out.fit.error)]
            };
    else
        runTitle = {
            ['Rspont=', num2str(decround(out.vars.RspontEvent, 0.001)), ' events/s, fc=', num2str(decround(out.vars.fc,0.1)), ', f1=', num2str(decround(out.vars.f1,0.1)), ', fc/f1=', num2str(decround(out.vars.fc/out.vars.f1,0.1))]
            ['LPForder=' num2str(out.vars.order) , ', M0=', num2str(out.vars.M0), ', b=', num2str(out.vars.b), ', D=', num2str(out.vars.D)]
            };
    end 

end