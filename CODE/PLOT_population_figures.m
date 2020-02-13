% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function creates and saves panels like those in Figures 6 and 7 of the 
% manuscript, using whatever fit results exist in the given subfolder of the 'FITS' 
% directory.
% ----------------------------------------------------------------------------------
function PLOT_population_figures(saveName)

    % Define load path and save path
    loadPath = ['FITS\' saveName ' (ZOOMED)\'];
    savePath = ['FITS\' saveName ' (POPULATION FIGURES)\'];

	% Create save path
    if ~exist(savePath,'dir')
        mkdir(savePath)
    end

    % Get the optimum results for each level series and M0
    optimum_per_M0 = get_optimum_per_M0(loadPath);

    % Get the optimum results for each levels series (i.e., compare across M0 values 
    % and identify the global best)
	optimum_overall = get_optimum_overall(optimum_per_M0);
    optimum_overall_constrained = get_optimum_overall_constrained(optimum_per_M0);

    % Create panels for Figures 6 and 7
    create_Fig6A(optimum_overall, savePath)
    create_Fig6B(optimum_overall, optimum_per_M0, savePath)
    create_Fig6C(optimum_overall, savePath)
    create_Fig6D(optimum_overall, savePath)
    create_Fig7A(optimum_overall, savePath)
    create_Fig7B(optimum_overall, savePath)
    create_Fig7C(optimum_overall, savePath)
    create_Fig7D(optimum_overall_constrained, savePath)
    create_Fig7E(optimum_overall_constrained, savePath)
    create_Fig7F(optimum_overall_constrained, savePath)

    disp(['Figures saved to ' savePath]);

end


% This function gets the optimum results for each level series and M0
% ----------------------------------------------------------------------------------
function optimum_per_M0 = get_optimum_per_M0(loadPath)

    resultFiles = rdir([loadPath '\*\*\*.mat']);
    nResultFiles = numel(resultFiles);
    if nResultFiles==0
        error('No zoomed fit results were found. Make sure your working directory is the one containing DEMO_FITTING.m and that the specified ''saveName'' is valid.')
    end

    % Initialize fields to store results
    optimum_per_M0 = [];
    optimum_per_M0.toneDB = cell(1,nResultFiles);
    optimum_per_M0.tonePa = cell(1,nResultFiles);
    optimum_per_M0.runName = cell(1,nResultFiles);
    optimum_per_M0.unitName = cell(1,nResultFiles);
    optimum_per_M0.f1 = nan(1,nResultFiles);    
    optimum_per_M0.RspontSpike = nan(1,nResultFiles);
    optimum_per_M0.RspontEvent = nan(1,nResultFiles);
    optimum_per_M0.threshold = nan(1,nResultFiles);
    optimum_per_M0.CF = nan(1,nResultFiles);
    optimum_per_M0.M0 = nan(1,nResultFiles);
    optimum_per_M0.b = nan(1,nResultFiles);
    optimum_per_M0.fc = nan(1,nResultFiles);
    optimum_per_M0.D = nan(1,nResultFiles);
    optimum_per_M0.error = nan(1,nResultFiles);
    
    for iFit = 1:nResultFiles

        % Open current file and get best results for HI and LO cutoffs
        currFile = load(resultFiles(iFit).name);

        % Identify whether parameters from HI or LO cutoff region is better
        if currFile.HI_out.fit.error < currFile.LO_out.fit.error
            out = currFile.HI_out;
        else
            out = currFile.LO_out;
        end
        
        % Clear unneeded copy of current file from memory
        clear currFile;

        % Store stimulus and ANF properties
        optimum_per_M0.toneDB{iFit} = out.data.toneDB;
        optimum_per_M0.tonePa{iFit} = out.data.tonePa;
        optimum_per_M0.VS{iFit} = out.data.VS;
        optimum_per_M0.runName{iFit} = out.data.runName;
        optimum_per_M0.f1(iFit) = out.data.f1;
        optimum_per_M0.RspontSpike(iFit) = out.data.RspontSpike;
        optimum_per_M0.RspontEvent(iFit) = out.vars.RspontEvent;
        optimum_per_M0.CF(iFit) = out.data.unitCF;
    
        % Store best fitting parameter values for current level series and M0
        optimum_per_M0.M0(iFit) = out.vars.M0;
        optimum_per_M0.b(iFit) = out.vars.b;
        optimum_per_M0.fc(iFit) = out.vars.fc;
        optimum_per_M0.D(iFit) = out.vars.D;
        optimum_per_M0.error(iFit) = out.fit.error;

        disp([num2str(iFit) ' of ' num2str(nResultFiles)]);
    end

end


% This function gets the overall optimum results for each levels series 
% (i.e., it compares results across M0 values and identifies the global best)
% ----------------------------------------------------------------------------------
function optimum_overall = get_optimum_overall(optimum_per_M0)

    % Get best fit results for each level series. Note that a 'run' below is 
    % synonymous with a 'level series'
    uniqueRunNames = unique(optimum_per_M0.runName);
    optimum_overall = [];
    for iRun = 1:numel(uniqueRunNames)
        runName = uniqueRunNames{iRun};
        idxRun = find(strcmp(runName, optimum_per_M0.runName));
        idxBest = idxRun(optimum_per_M0.error(idxRun)==min(optimum_per_M0.error(idxRun)));

        optimum_overall.toneDB{iRun} = optimum_per_M0.toneDB{idxBest};
        optimum_overall.tonePa{iRun} = optimum_per_M0.tonePa{idxBest};
        optimum_overall.VS{iRun} = optimum_per_M0.VS{idxBest};
        optimum_overall.f1(iRun) = optimum_per_M0.f1(idxBest);
        optimum_overall.CF(iRun) = optimum_per_M0.CF(idxBest);
        optimum_overall.M0(iRun) = optimum_per_M0.M0(idxBest);
        optimum_overall.b(iRun) = optimum_per_M0.b(idxBest);
        optimum_overall.fc(iRun) = optimum_per_M0.fc(idxBest);
        optimum_overall.D(iRun) = optimum_per_M0.D(idxBest);
        optimum_overall.RspontSpike(iRun) = optimum_per_M0.RspontSpike(idxBest);
        optimum_overall.RspontEvent(iRun) = optimum_per_M0.RspontEvent(idxBest);
        optimum_overall.runName{iRun} = optimum_per_M0.runName{idxBest};

    end

end


% This function gets the overall optimum results but with M0 constrained to >= 0.3
% ----------------------------------------------------------------------------------
function optimum_overall = get_optimum_overall_constrained(optimum_per_M0)

    min_M0_allowed = 0.3;
    idxDel = optimum_per_M0.M0 < min_M0_allowed;
    
    fieldNames = fieldnames(optimum_per_M0);
    for iField = 1:numel(fieldNames)
        optimum_per_M0.(fieldNames{iField})(idxDel) = [];
    end

    optimum_overall = get_optimum_overall(optimum_per_M0);

end


% These functions create and save the individual panels like those in the manuscript
% ----------------------------------------------------------------------------------
function create_Fig6A(optimum_overall, savePath)

    figure
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();

    sub.select(1,1); hold all;
    scatter(optimum_overall.f1./1000, optimum_overall.M0, 20, log(optimum_overall.RspontEvent), 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5]);
    xlog()
    xlabel('f1 (kHz)')
    ylabel('M0')
    xlim([0.1 10])
    ylim([0 1])
    set(gca,'XTick',[0.1 1 10],'XTickLabel',getLabel([0.1 1 10]))
    set(gca,'YTick',[0 0.25 0.5 0.75 1],'YTickLabel',getLabel([0 0.25 0.5 0.75 1]))
    colorbar_SR(gca);
    colorbar off;
    box off
    M0_list = 0.05:0.05:0.95;
    for M0=M0_list
        h = plot(xlim, [M0 M0], '-', 'Color', [0.7 0.7 0.7]);
        uistack(h,'bottom')
    end
    
    axes('Position', [0.592405063291139   0.607594936708861   0.193607594936709   0.172151898734178], 'FontSize', 12)    
    histogram(optimum_overall.M0, 'BinEdges', 0.025:0.05:1, 'FaceColor', [0.7 0.7 0.7])
    xlim([-0.02 1.02])
    ylim([0 55])
    set(gca,'XTick', [0.1 0.5 0.9])
    set(gca,'YTick', [0 25 50])
    set(gca,'FontSize', 8)
    xlabel('M0')
    ylabel('Count')

    saveas(gcf, [savePath 'Fig6A.fig'])
    saveas(gcf, [savePath 'Fig6A.svg'])
    saveas(gcf, [savePath 'Fig6A.png'])

end

function create_Fig6B(optimum_overall, optimum_per_M0, savePath)

    figure; 
    sub = subplotter('vpadding', 0, 'hpadding', 4, 'lmargin', 100, 'rmargin', 100, 'tmargin', 100, 'bmargin', 100);
    sub.add(1,1,'size',[72 225]);
    sub.add(1,2,'size',[72 225]);
    sub.add(1,3,'size',[72 225]);
    sub.build();

    for i=1:3
        sub.select(1,i);
        if i==1
            set(gca,'XTickLabel', {'0' '' '' '' '' '0.5' '' '' '' '' '1'});
            set(gca,'YTickLabel', getLabel([0 1000 2000 3000 4000]))
            xlabel('M0')
            ylabel('NLOGL difference')
        else
            set(gca,'XTickLabel', {'' '' '' '' '' '' '' '' '' '' ''});
            set(gca,'YTickLabel', {'' '' '' '' '' ''})
        end
        xlim([0 1])
        ylim([-100 4000])
        set(gca,'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
        set(gca,'YTick',[0 1000 2000 3000 4000])
        colorbar_f1(gca);
        colorbar off;
        colormap(inferno)
        box off
        
        set(gca,'FontSize', 10)

    end

    [~,idxSortByToneHz] = sort(optimum_overall.f1);

    for iRun = idxSortByToneHz
        idxRun = strcmp(optimum_overall.runName(iRun), optimum_per_M0.runName);
        if optimum_overall.RspontEvent(iRun)<=1
            sub.select(1,3); hold all;
        elseif optimum_overall.RspontEvent(iRun)>1 && optimum_overall.RspontEvent(iRun)<10
            sub.select(1,2); hold all;
        elseif optimum_overall.RspontEvent(iRun)>=10
            sub.select(1,1); hold all;
        end

        CData = log(optimum_overall.f1(iRun));
        climits = caxis;
        cmap = inferno;
        scalarclamped = CData;
        scalarclamped(CData < climits(1)) = climits(1);
        scalarclamped(CData > climits(2)) = climits(2);
        C = interp1(linspace(climits(1), climits(2), size(cmap, 1)), cmap, scalarclamped);
        h = plot(optimum_per_M0.M0(idxRun), optimum_per_M0.error(idxRun)-min(optimum_per_M0.error(idxRun)), '.-', 'Color', C, 'LineWidth', 1);
        uistack(h,'top');
    end

    saveas(gcf, [savePath 'Fig6B.fig'])
    saveas(gcf, [savePath 'Fig6B.svg'])
    saveas(gcf, [savePath 'Fig6B.png'])

end

function create_Fig6C(optimum_overall, savePath)

    figure
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();
    sub.select(1,1); hold all;

    % Get the 'lowest level included' in the optimum_overall. However, spurious results are 
    % excluded by taking the lowest level for which the next-highest level tested
    % is also present (if it's not present, then presumably the ANF did not really
    % yet reach 'threshold')
    optimum_overall.lowest_level = nan(size(optimum_overall.f1));
    for i=1:numel(optimum_overall.toneDB)
        dB = optimum_overall.toneDB{i};
        d_dB = diff(dB);
        maxShift = find(d_dB == mode(d_dB), 1, 'first');
        idxExclude = find(d_dB > mode(d_dB));
        idxExclude = idxExclude(idxExclude <= maxShift);
        dB(idxExclude) = [];
        optimum_overall.lowest_level(i) = min(dB);
    end
    
    % Plot result
    scatter3(optimum_overall.lowest_level, optimum_overall.b, 1:numel(optimum_overall.RspontEvent), 20, log(optimum_overall.RspontEvent), 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5]);
    view([0 0 90])
    ylog()
    xlabel('Lowest level included (dB SPL)')
    ylabel('b')
    xlim([-5 105])
    ylim([8 100000])
    set(gca,'XTick',0:20:100,'XTickLabel',getLabel(0:20:100))
    set(gca,'YTick',[1e-2 1e-1 1e0 1e1 1e2 1e3 1e4 1e5 1e6],'YTickLabel',getLabel([1e-2 1e-1 1e0 1e1 1e2 1e3 1e4 1e5 1e6]))
    colorbar_SR(gca)
    colorbar off;
    box off;

    saveas(gcf, [savePath 'Fig6C.fig'])
    saveas(gcf, [savePath 'Fig6C.svg'])
    saveas(gcf, [savePath 'Fig6C.png'])    
    
end

function create_Fig6D(optimum_overall, savePath)

    figure
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();

    sub.select(1,1); hold all;
    [~,idxSortByToneHz] = sort(optimum_overall.f1);
    colorbar_f1(gca)
    colorbar off;
    colormap(gca, inferno)
    for idxRun = idxSortByToneHz
        CData = log(optimum_overall.f1(idxRun));
        climits = caxis;
        cmap = inferno;
        scalarclamped = CData;
        scalarclamped(CData < climits(1)) = climits(1);
        scalarclamped(CData > climits(2)) = climits(2);
        C = interp1(linspace(climits(1), climits(2), size(cmap, 1)), cmap, scalarclamped);

        h = plot(optimum_overall.b(idxRun).*optimum_overall.tonePa{idxRun}, optimum_overall.VS{idxRun}, '.-', 'Color', C, 'LineWidth', 1);
        uistack(h,'bottom');
    end
    view([0 0 90])
    xlog()
    xlabel('b * tonePa')
    ylabel('Vector strength')
    xlim([1e-3 1e5])
    set(gca,'XTick',[1e-2 1e0 1e2 1e4],'XTickLabel',getLabel([1e-2 1e0 1e2 1e4]))
    set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',getLabel([0 0.2 0.4 0.6 0.8 1]))
    box off

    saveas(gcf, [savePath 'Fig6D.fig'])
    saveas(gcf, [savePath 'Fig6D.svg'])
    saveas(gcf, [savePath 'Fig6D.png'])

end

function create_Fig7A(optimum_overall, savePath)

    figure
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();
    sub.select(1,1); hold all;

    scatter(optimum_overall.f1./1000, optimum_overall.fc./1000, 20, log(optimum_overall.RspontEvent), 'o', 'fill', 'MarkerEdgeColor', [0.5 0.5 0.5])
    xlog()
    ylog()
    xlabel('f1')
    ylabel('fc')
    xlim([0.1 10])
    ylim([0.1 10])
    set(gca,'XTick',[0.1 1 10],'XTickLabel',getLabel([0.1 1 10]))
    set(gca,'YTick',[0.1 1 10],'YTickLabel',getLabel([0.1 1 10]))
    colorbar_SR(gca)
    colorbar off;
    plotDiagonal()
    box off;

    saveas(gcf, [savePath 'Fig7A.fig'])
    saveas(gcf, [savePath 'Fig7A.svg'])
    saveas(gcf, [savePath 'Fig7A.png'])    

end

function create_Fig7B(optimum_overall, savePath)

    figure; 
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();
    sub.select(1,1); hold all;

    order = 3;
    G = 1./(sqrt(1+(optimum_overall.f1./optimum_overall.fc).^(2*order)));
    scatter(optimum_overall.f1./1000, G, 20, log(optimum_overall.RspontEvent), 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5]);
    xlog()
    ylog()
    xlabel('f1 (kHz)')
    ylabel('Gain')
    xlim([0.1 10])
    ylim([0.01 1])
    set(gca,'XTick',[0.1 1 10],'XTickLabel',getLabel([0.1 1 10]))
    set(gca,'YTick',[0.01 0.1 1],'YTickLabel',getLabel([0.01 0.1 1]))
    colorbar_SR(gca);
    colorbar off;
    box off

    saveas(gcf, [savePath 'Fig7B.fig'])
    saveas(gcf, [savePath 'Fig7B.svg'])
    saveas(gcf, [savePath 'Fig7B.png'])

end

function create_Fig7C(optimum_overall, savePath)

    figure
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();

    sub.select(1,1); hold all;
    scatter(optimum_overall.RspontEvent, optimum_overall.D, 15, 'k', 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5])
    xlog()
    ylog()
    xlabel('Rspont (events/s)')
    ylabel('Slope factor D')
    ylim([1 1000])
    xlim([0.01 120])
    set(gca,'XTick', [0.001 0.01 0.1 1 10 100],'XTickLabel', getLabel([0.001 0.01 0.1 1 10 100]))
    set(gca,'YTick', [0.01 0.1 1 10 100 1000],'YTickLabel', getLabel([0.01 0.1 1 10 100 1000]))
    box off

    saveas(gcf, [savePath 'Fig7C.fig'])
    saveas(gcf, [savePath 'Fig7C.svg'])
    saveas(gcf, [savePath 'Fig7C.png']) 
 
end

function create_Fig7D(optimum_overall, savePath)

    figure
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();
    sub.select(1,1); hold all;

    scatter(optimum_overall.f1./1000, optimum_overall.fc./1000, 20, log(optimum_overall.RspontEvent), 'o', 'fill', 'MarkerEdgeColor', [0.5 0.5 0.5])
    xlog()
    ylog()
    xlabel('f1')
    ylabel('fc')
    xlim([0.1 10])
    ylim([0.1 10])
    set(gca,'XTick',[0.1 1 10],'XTickLabel',getLabel([0.1 1 10]))
    set(gca,'YTick',[0.1 1 10],'YTickLabel',getLabel([0.1 1 10]))
    colorbar_SR(gca)
    colorbar off;
    plotDiagonal()
    box off;

    saveas(gcf, [savePath 'Fig7D.fig'])
    saveas(gcf, [savePath 'Fig7D.svg'])
    saveas(gcf, [savePath 'Fig7D.png'])    

end

function create_Fig7E(optimum_overall, savePath)

    figure; 
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();
    sub.select(1,1); hold all;

    order = 3;
    G = 1./(sqrt(1+(optimum_overall.f1./optimum_overall.fc).^(2*order)));
    scatter(optimum_overall.f1./1000, G, 20, log(optimum_overall.RspontEvent), 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5]);
    xlog()
    ylog()
    xlabel('f1 (kHz)')
    ylabel('Gain')
    xlim([0.1 10])
    ylim([0.01 1])
    set(gca,'XTick',[0.1 1 10],'XTickLabel',getLabel([0.1 1 10]))
    set(gca,'YTick',[0.01 0.1 1],'YTickLabel',getLabel([0.01 0.1 1]))
    colorbar_SR(gca);
    colorbar off;
    box off

    saveas(gcf, [savePath 'Fig7E.fig'])
    saveas(gcf, [savePath 'Fig7E.svg'])
    saveas(gcf, [savePath 'Fig7E.png'])

end

function create_Fig7F(optimum_overall, savePath)

    figure
    sub = subplotter();
    sub.add(1,1,'size',[225 225]);
    sub.build();

    sub.select(1,1); hold all;
    scatter(optimum_overall.RspontEvent, optimum_overall.D, 15, 'k', 'filled', 'MarkerEdgeColor', [0.5 0.5 0.5])
    xlog()
    ylog()
    xlabel('Rspont (events/s)')
    ylabel('Slope factor D')
    ylim([1 1000])
    xlim([0.01 120])
    set(gca,'XTick', [0.001 0.01 0.1 1 10 100],'XTickLabel', getLabel([0.001 0.01 0.1 1 10 100]))
    set(gca,'YTick', [0.01 0.1 1 10 100 1000],'YTickLabel', getLabel([0.01 0.1 1 10 100 1000]))
    box off

    saveas(gcf, [savePath 'Fig7F.fig'])
    saveas(gcf, [savePath 'Fig7F.svg'])
    saveas(gcf, [savePath 'Fig7F.png']) 
 
end
