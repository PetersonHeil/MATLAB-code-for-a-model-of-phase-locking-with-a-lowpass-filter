% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function plots the model functions for the level series
% ----------------------------------------------------------------------------------
function PLOT_demo_level_series(out, h)

    if nargin<2
        h = figure();
        sub = subplotter();
        sub.add(1,1,'size',[550 100]);
        sub.build();
        sub.select(1,1); hold all;
    else
        set(gcf,'CurrentAxes',h)
    end

    % Count number of stimulus pressures
    nPressures = numel(out.vars.tonePa);
    
    C = colorGradient([0 0 1], [1 0 0], nPressures);    
    set(gca,'FontSize', 11);
	nPoints = numel(out.model.Revent_per_pressure(1,:));

    % Preallocate variables for results
    XStart = numel(out.model.t_ms);
    XEnd = numel(out.model.t_ms);
    XStart(1) = 1;

    % Step through each stimulus pressure
    for iPressure=1:nPressures
        XEnd(iPressure) = XStart(iPressure)+nPoints-1;
        bar(linspace(XStart(iPressure),XEnd(iPressure), numel(out.model.Revent_per_pressure(iPressure,:))), out.model.Revent_per_pressure(iPressure,:), 'FaceColor', C(iPressure,:), 'EdgeColor',C(iPressure,:));        
        plot(XStart(iPressure):XEnd(iPressure), out.model.Revent_per_pressure(iPressure,:), '-k', 'LineWidth', 2.5);
        plot(XStart(iPressure):XEnd(iPressure), out.model.Revent_per_pressure(iPressure,:), '-w', 'LineWidth', 1);
        XStart(iPressure+1) = XEnd(iPressure) + round(nPoints/10);
    end

    axis tight;
    ylim([0 decround(max(out.model.Revent_concatenated), 100, @ceil)])

    plot(xlim, [out.vars.RspontEvent out.vars.RspontEvent], ':', 'Color', [1 1 1], 'LineWidth', 1);    
    
    XTicks = mean([XStart(1:end-1);XEnd]);
    set(gca,'XTick',XTicks, 'XTickLabel', decround(pa2db(out.vars.tonePa),0.1))
    box on

    xlabel('Stimulus level (dB SPL)', 'FontSize', 12)
    ylabel('Instantaneous release rate', 'FontSize', 12)
    box off
    
    runTitle = PLOT_getRunTitle(out);
    title(runTitle);

end
