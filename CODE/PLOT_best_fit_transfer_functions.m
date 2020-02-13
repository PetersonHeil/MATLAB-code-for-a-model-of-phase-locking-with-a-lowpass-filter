% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function plots the "overall" transfer functions for the level series
% ----------------------------------------------------------------------------------
function PLOT_best_fit_transfer_functions(out, h)

    if nargin<2
        h = figure();
        sub = subplotter();
        sub.add(1,1,'size',[225 225]);
        sub.build();
        sub.select(1,1); hold all;
    else
        set(gcf,'CurrentAxes',h)
    end

    nPressures = numel(out.vars.tonePa);
    C = colorGradient([0 0 1], [1 0 0], nPressures);    
    set(gca,'FontSize', 11);

    for iPressure=1:nPressures

        Pt = out.model.Pt_per_pressure(iPressure,:);
        Rt = out.model.Revent_per_pressure(iPressure,:);
        plot(Pt, Rt, 'LineWidth', 1, 'Color', C(iPressure,:));

    end

    axis tight
    ylim([1e-2 1e4])
    xlabel('Instant. pressure (Pa)', 'FontSize', 12)
    ylabel('Release rate (events/s)', 'FontSize', 12)

    YTick = [1e-2 1e-1 1e-0 1e1 1e2 1e3 1e4];
    set(gca,'YTick',YTick)
    set(gca,'YTickLabel', arrayfun(@num2str, YTick, 'UniformOutput', false))
    ylim([0.01 1000])
    set(gca,'YScale','log')
    
    plot(xlim, [out.vars.RspontEvent out.vars.RspontEvent], ':', 'Color', [0 0 0], 'LineWidth', 1);    
    
    % Set title
    runName = out.data.runName;
    toneDB = out.data.toneDB;
    f1 = out.data.f1;
    toneOctavesFromCF = out.data.toneOctavesFromCF;
    runSponRate = out.data.RspontSpike;
    dBrange = [num2str(min(toneDB)) ':' num2str(mode(diff(toneDB))) ':' num2str(max(toneDB)) ' dB SPL'];
    title({
        'New model with LPF'
        [runName '    ' dBrange]
        [num2str(decround(f1./1000, 0.01)) ' kHz (', num2str(decround(toneOctavesFromCF,0.01)) ' octaves), ' num2str(decround(runSponRate, 0.01)) ' sp/s']
        })

    box off;
    
    end