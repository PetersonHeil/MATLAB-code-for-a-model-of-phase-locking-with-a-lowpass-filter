% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function plots the "overall A"-versus-level and "overall B"-versus level 
% functions for the level series
% ----------------------------------------------------------------------------------
function PLOT_best_fit_overall_A_and_B(out, sub)

    % Compute equivalent A and B
    toneDB = out.data.toneDB;
    tonePa = out.data.tonePa;
    nPressures = numel(tonePa);
    VS = nan(1,nPressures);
    Rmean = nan(1,nPressures);
    for iPressure = 1:nPressures
        Revent = out.model.Revent_per_pressure(iPressure,:);
        Rmean(iPressure) = mean(Revent);
        VS(iPressure) = calculateVSFromPHIST(Revent, 'omitRightBin', true);
    end
    
    try
        BP1 = get_BP1(VS);
    catch
        warning('WARNING: VS outside of valid range for computing relative B. Ignoring and continuing.')
        BP1 = nan(size(VS));
    end
    
    sub.select(2,1); hold all;
    A_equivalent = Rmean./besseli(0, BP1);
    C = colorGradient([0 0 1], [1 0 0], nPressures);
    for iPressure = 1:nPressures
        plot(toneDB(iPressure), A_equivalent(iPressure), '.', 'Color', C(iPressure,:), 'MarkerSize', 15);
    end
    xlim([-5 105])
    ylim([0.01 1000])
    set(gca,'YTick', [0.01 0.1 1 10 100 1000],'YTickLabel', getLabel([0.01 0.1 1 10 100 1000]))
    ylog
    xlabel('Stimulus level (dB SPL)')
    ylabel('Overall A (events/s)')
    h = plot(xlim, [out.vars.RspontEvent out.vars.RspontEvent], ':', 'Color', [0 0 0], 'LineWidth', 1);
    uistack(h,'bottom')
    box off

    sub.select(2,2); hold all;
    B_equivalent = (BP1./tonePa);
	plot(0:110, 1./db2pa(0:110), ':', 'Color', [0 0 0], 'LineWidth', 1);
    C = colorGradient([0 0 1], [1 0 0], nPressures);
    for iPressure = 1:nPressures
        plot(toneDB(iPressure), B_equivalent(iPressure), '.', 'Color', C(iPressure,:), 'MarkerSize', 15);
    end
    xlim([-5 105])
    ylim([0.1 10000])
    set(gca,'YTick', [0.1 1 10 100 1000 10000],'YTickLabel', getLabel([0.1 1 10 100 1000 10000]))
    ylog
    xlabel('Stimulus level (dB SPL)')
    ylabel('Overall B (1/Pa)')
    box off


    % Compute extrapolated A- and B-versus-level functions
    toneDB = -5:1:105;
    tonePa = db2pa(toneDB);
    nPressures = numel(tonePa);
    outExtrapolate = out;
    outExtrapolate.vars.tonePa = tonePa;
    outExtrapolate.data.nReps = ones(1,nPressures);
    outExtrapolate = MODEL_MET_LPF(outExtrapolate);
    outExtrapolate = MODEL_Rate(outExtrapolate);
    VS = nan(1,nPressures);
    Rmean = nan(1,nPressures);
    for iPressure = 1:nPressures
        Revent = outExtrapolate.model.Revent_per_pressure(iPressure,:);
        Rmean(iPressure) = mean(Revent);
        VS(iPressure) = calculateVSFromPHIST(Revent, 'omitRightBin', true);
    end
    
    try
        BP1 = get_BP1(VS);
    catch
        warning('WARNING: VS outside of valid range for computing relative B. Ignoring and continuing.')
        BP1 = nan(size(VS));
    end
    
    A_equivalent = Rmean./besseli(0, BP1);
    B_equivalent = (BP1./tonePa);
    sub.select(2,1);
    h = plot(toneDB, A_equivalent, '-', 'Color', [0 0 0]);
    uistack(h,'bottom') 
    sub.select(2,2);
    h = plot(toneDB, B_equivalent, '-', 'Color', [0 0 0]);
    uistack(h,'bottom')

end