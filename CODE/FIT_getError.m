% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function returns the error for a given value of D.
% For this project, 'errorToMinimize' is set to NLOGL (negative log likelihood)
% ----------------------------------------------------------------------------------
function runError = FIT_getError(D, out)

    % Set free parameter value and recompute model output
    out.vars.D = D;
    out = MODEL_Rate(out);

    % Compute error measure
    switch out.vars.errorToMinimize
        case 'SSE'  % Ordinary least squares ("mean regression")
			error('SSE not implemented');
        case 'SE'  % Sum of errors ("median regression" or "quantile regression")
			error('SE not implemented');
        case 'NLOGL'
            nEventsData = out.data.phist.Nevent_concatenated;
            nEventsModel = out.model.Nevent_concatenated;

            % Calculate likelihood of observations from continuous Poisson
            % and add a tiny constant to all values to prevent any Pr=0
            Pr = poisson(nEventsData,nEventsModel) + realmin('double');

            % Calculate (negative log) joint likelihood
            runError = sum(-log(Pr));

            % If error is infinite, set to absurdly large finite value instead
            if isinf(runError)
                runError = 1e100;
            end
        otherwise
            error('ERROR: A valid ''error to minimize'' must be supplied.')
    end

end