% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function calculates the model output for two stages, the MET current and the LPF output
% ----------------------------------------------------------------------------------
function out = MODEL_MET_LPF(out)

    % Create time vector
    t_ms = decround(0:out.vars.dt_ms:out.vars.tMax_ms, out.vars.dt_ms);

    % Get the time series for each period histogram and the stimulus period T_rounded.
    % This might not correspond perfectly to the specified f1, because T_rounded must 
    % be an integer multiple of the time step dt_ms.
    if isfield(out,'data') && isfield(out.data,'phist')
        tCycle = out.data.phist.t_ms;
        T_rounded = tCycle(end);
    else
        T_rounded = 1000/out.vars.f1;
        tCycle = 0:out.vars.dt_ms:T_rounded;
        T_rounded = tCycle(end);
    end

    % Compute stimulus frequency f1_rounded which corresponds to T_rounded. This will
    % usually be *slightly* higher than the original f1 because the number of bins
    % in the period histogram is the floor of the number of bins fitting into the
    % period of the original f1. This new frequency, f1_rounded, is used in the
    % model to avoid strange things which sometimes happen during filtering.
    out.vars.f1_rounded = 1000./decround(T_rounded+out.vars.dt_ms, out.vars.dt_ms);

    % Count nubmer of points per cycle
	nPointsPerCycle = numel(tCycle);

    % Count number of cycles to simulate
    nCycles = numel(t_ms)/nPointsPerCycle;

    % Create upsampled time vector to be used in filtering step (this yields more
    % precise results). If you want to turn it off, set upSampleFactor = 1.
    upsampleFactor = 10;
    dt_upsampled = out.vars.dt_ms/upsampleFactor;
    tCycle_upsampled = decround(0:dt_upsampled:(T_rounded+out.vars.dt_ms-dt_upsampled), dt_upsampled);
    t_upsampled = decround(0:dt_upsampled:out.vars.tMax_ms, dt_upsampled);  
    
    % Create unit waveform with amplitude of 1 Pa
    Pt_one = sin(2.*pi.*out.vars.f1_rounded./1000.*tCycle_upsampled);
    Pt_one = repmat(Pt_one, 1, ceil(nCycles));
    Pt_one = Pt_one(1:numel(t_upsampled));

    % Compute filter coefficients
    fs = 1/dt_upsampled*1000;
	Nyquist = fs/2;
    Wn = out.vars.fc/Nyquist;
    
    % Get Butterworth filter coefficients
    [out.vars.filtB, out.vars.filtA] = butter(out.vars.order, Wn, 'low');

    % Count number of sound pressures
    nPressures = numel(out.vars.tonePa);

    % Preallocate variables for results
    Pt_per_pressure = nan(nPressures, numel(t_ms));
    METcurrent_per_pressure = nan(nPressures, numel(t_ms));
    LPFoutput_per_pressure = nan(nPressures, numel(t_ms));
    
    % Step through each stimulus pressure
    for iPressure = 1:nPressures
        
        % Create stimulus waveform by scaling the unit waveform
        Pt_upsampled = out.vars.tonePa(iPressure).* Pt_one;

        % Convert waveform of stimulus pressure to MET current
        METcurrent_upsampled = 1 ./(1+(1/out.vars.M0-1).*exp(-out.vars.b.*Pt_upsampled));

        % Convert waveform of MET current to IHC filter output
        LPFoutput_upsampled = filter(out.vars.filtB, out.vars.filtA, METcurrent_upsampled(:))';

        % Downsample all signals after filtering
        Pt_per_pressure(iPressure,:) = Pt_upsampled(1:upsampleFactor:end);
        METcurrent_per_pressure(iPressure,:) = METcurrent_upsampled(1:upsampleFactor:end);
        LPFoutput_per_pressure(iPressure,:) = LPFoutput_upsampled(1:upsampleFactor:end);

    end
    
    % Remove upsampled time series, because they are quite large
    clear Pt_upsampled
    clear METcurrent_upsampled
    clear LPFoutput_upsampled

    % Store time vector for one cycle
	out.model.t_ms = t_ms(1:nPointsPerCycle);    

    % Get index of bins in the center cycle
    center_idxStart = find(t_ms==decround(out.vars.tMax_ms/2, out.vars.dt_ms));
    center_idxEnd = center_idxStart + nPointsPerCycle-1;
    center_idxCenter = center_idxStart:center_idxEnd;

    % Store center cycle of each signal
    out.model.Pt_per_pressure = Pt_per_pressure(:, center_idxCenter);
    out.model.METcurrent_per_pressure = METcurrent_per_pressure(:, center_idxCenter);
    out.model.LPFoutput_per_pressure = LPFoutput_per_pressure(:, center_idxCenter);
    
    % Shift the phase angles of the mean vectors to the specified values
    out = shiftPhase(out);

end

% ----------------------------------------------------------------------------------
% This function shifts each period histogram to align mean phase to specified value
% ----------------------------------------------------------------------------------
function out = shiftPhase(out)

    % Count the number of stimulus pressures
    nPressures = numel(out.vars.tonePa);

    % Step through each sound pressure
    for iPressure=1:nPressures

        % Attempt to shift the phase of the output        
        try
            % Shift Pt to align the phase angle of the mean vector
            if isfield(out.vars, 'goalMeanPhasePt')
                goalMeanPhase = out.vars.goalMeanPhasePt;
                [~, currMeanPhase] = calculateVSFromPHIST(out.model.Pt_per_pressure(iPressure,:), 'omitRightBin', true);
                phase_diff = currMeanPhase-goalMeanPhase;
                rel_shift_cycles = phase_diff/(2*pi);
                rel_shift_bins = round(rel_shift_cycles.*(1000./out.vars.f1_rounded)./out.vars.dt_ms);
                out.model.Pt_per_pressure(iPressure,:) = circshift(out.model.Pt_per_pressure(iPressure,:), -rel_shift_bins);
            end
            % Shift MET current to align the phase angle of the mean vector
            if isfield(out.vars, 'goalMeanPhaseMET')
                goalMeanPhase = out.vars.goalMeanPhaseMET;
                [~, currMeanPhase] = calculateVSFromPHIST(out.model.METcurrent_per_pressure(iPressure,:), 'omitRightBin', true);
                phase_diff = currMeanPhase-goalMeanPhase;
                rel_shift_cycles = phase_diff/(2*pi);
                rel_shift_bins = round(rel_shift_cycles.*(1000./out.vars.f1_rounded)./out.vars.dt_ms);
                out.model.METcurrent_per_pressure(iPressure,:) = circshift(out.model.METcurrent_per_pressure(iPressure,:), -rel_shift_bins);
            end
            % Shift LPFoutput to align the phase angle of the mean vector
            if isfield(out.vars, 'goalMeanPhaseLPF')
                goalMeanPhase = out.vars.goalMeanPhaseLPF;
                [~, currMeanPhase] = calculateVSFromPHIST(out.model.LPFoutput_per_pressure(iPressure,:), 'omitRightBin', true);
                phase_diff = currMeanPhase-goalMeanPhase;
                rel_shift_cycles = phase_diff/(2*pi);
                rel_shift_bins = round(rel_shift_cycles.*(1000./out.vars.f1_rounded)./out.vars.dt_ms);
                out.model.LPFoutput_per_pressure(iPressure,:) = circshift(out.model.LPFoutput_per_pressure(iPressure,:), -rel_shift_bins);                
            end
        catch
            warning('Cannot shift Pt, MET, or LPFoutput. Probably contains all zeros or has infs.')
        end

    end

end
