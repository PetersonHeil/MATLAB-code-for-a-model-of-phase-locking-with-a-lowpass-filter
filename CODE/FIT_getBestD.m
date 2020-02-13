% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function performs the optimization of parameter D
% ----------------------------------------------------------------------------------
function out = FIT_getBestD(out)

    % Specify error function to be minimized
    funToMinimize = @(x) FIT_getError(x,out);

    % Call optimization function and get error
    INITIALS = [out.vars.D];
    LB = out.vars.lb;
    UB = out.vars.ub;
    [fittedD,fittedError] = fmincon(funToMinimize,INITIALS,[],[],[],[],LB,UB,[],out.vars.options);

    % Recompute and store model results for the best fitting D
    out.vars.D = fittedD;
    out = MODEL_Rate(out);

    % Save best values
    out.fit.D = fittedD;
	out.fit.error = fittedError;
    out.fit.finals.D = fittedD;
    out.fit.finals.paramNames = out.vars.paramNames;

end

