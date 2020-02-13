% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function calculates the model output for the rate of release events
% ----------------------------------------------------------------------------------
function out = MODEL_Rate(out)

    % Convert IHC filter output to rate of release events
    out.model.Revent_per_pressure = out.vars.RspontEvent .*exp(out.vars.D.*(out.model.LPFoutput_per_pressure - out.vars.M0));
    if any(isinf(out.model.Revent_per_pressure))
        warning('Rate calculation has inf values.')
    end

    % Shift the phase angles of the mean vectors to the specified values
    out = shiftPhase(out);

    % Rearrange results from each stimulus pressure into one continuous vector
    out.model.Revent_concatenated = out.model.Revent_per_pressure';
    out.model.Revent_concatenated = out.model.Revent_concatenated(:);

    % If fitting data, compute the number of events expected per bin, assuming 
    % that the number of model cycles equals the number of cycles used to compute 
    % the period histogram from the data.
    if isfield(out,'data') && isfield(out.data,'phist')
        cyclesPerRep = out.data.phist.cyclesPerRep;
        repCount = out.data.nReps;
        conversionFactors = out.vars.dt_ms.*cyclesPerRep.*repCount'./1000;
        Nevent_per_pressure = conversionFactors .* out.model.Revent_per_pressure;
        
        % Rearrange results from each stimulus pressure into one continuous vector
        Nevent_concatenated = Nevent_per_pressure';
        out.model.Nevent_concatenated = Nevent_concatenated(:);
    end

end


% ----------------------------------------------------------------------------------
% This function shifts each period histogram to align mean phase to specified value
% ----------------------------------------------------------------------------------
function out = shiftPhase(out)

    % Count the number of stimulus pressures
    nPressures = numel(out.vars.tonePa);

    % Step through each sound pressure
    for i=1:nPressures

        % Attempt to shift the phase of the output
        try
            if isfield(out.vars, 'goalMeanPhaseRate')
                goalMeanPhase = out.vars.goalMeanPhaseRate;
                [~, currMeanPhase] = calculateVSFromPHIST(out.model.Revent_per_pressure(i,:), 'omitRightBin', true);
                phase_diff = currMeanPhase-goalMeanPhase;
                rel_shift_cycles = phase_diff/(2*pi);
                rel_shift_bins = round(rel_shift_cycles.*(1000./out.vars.f1_rounded)./out.vars.dt_ms);
                out.model.Revent_per_pressure(i,:) = circshift(out.model.Revent_per_pressure(i,:), -rel_shift_bins);
            end
        catch
            warning('Cannot shift Revent. Probably contains all zeros or has infs.')
        end

    end

end

