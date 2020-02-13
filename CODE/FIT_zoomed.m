% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function is responsible for coordinating the second round of fits. It should 
% be called after using FIT_prelim.m to perform the first round of fits. It is very 
% similar to FIT_prelim.m, except it loads the previous results and uses them to 
% define new grid values for zooming in.
% ----------------------------------------------------------------------------------
function FIT_zoomed(data, M0, saveName)

    % Define load path and save path
    loadPath = ['FITS\' saveName ' (PRELIM)\M0=' num2str(M0) '\' data.runName '\'];
    savePath = ['FITS\' saveName ' (ZOOMED)\M0=' num2str(M0) '\' data.runName '\'];

    % Check if preliminary fits exists before continuing
    if exist(loadPath,'dir')
        
        % Load preliminary fits
        PRELIM_RESULTS = load([loadPath data.runName '.mat']);

        % Create save path
        if ~exist(savePath,'dir')
            mkdir(savePath)
        end

        disp(['Fitting run ' data.runName ' with M0 fixed to ' num2str(M0) '...']);

        % Create figure to display grid results
        figure();

        % Layout figure using my own figure layout class called subplotter.m
        sub = subplotter('rmargin', 100);
        sub.add(1,1,'size',[300 300]);
        sub.add(1,2,'size',[300 300]);
        sub.build();

        % --------------------------------------------------------------------------
        % For "LO" cutoff frequencies (i.e., those less than or equal to stimulus)
        % --------------------------------------------------------------------------

        % Configure the input/output structure (function is located at the bottom of
        % this file)
        LO_out = PRELIM_RESULTS.LO_out;
        LO_out = configure_options(LO_out);

        % Perform fits and get best-fitting results
        sub.select(1,1); hold all;
        LO_out = FIT_grid(LO_out, gca);

        % Plot and save figure showing best fit
        PLOT_best_fit(LO_out);
        saveas(gcf,[savePath LO_out.data.runName ' LO BEST FIT.png'])
        close(gcf);

        % --------------------------------------------------------------------------
        % For "HI" cutoff frequencies (i.e., those greater than or equal to stimulus)
        % --------------------------------------------------------------------------

        % Configure the input/output structure (function is located at the bottom of
        % this file)
        HI_out = PRELIM_RESULTS.HI_out;
        HI_out = configure_options(HI_out);

        % Perform fits and get best-fitting results
        sub.select(1,2); hold all;
        HI_out = FIT_grid(HI_out, gca);

        % Plot and save figure showing best fit
        PLOT_best_fit(HI_out);
        saveas(gcf,[savePath HI_out.data.runName ' HI BEST FIT.png'])
        close(gcf);

        % --------------------------------------------------------------------------        

        % Determine whether HI or LO fits better, adjust color scale, add colorbar
        PLOT_updateGrids(sub, LO_out, HI_out)    

        % Save grids figure
        saveas(gcf,[savePath data.runName ' SPLIT GRID.png'])
        saveas(gcf,[savePath data.runName ' SPLIT GRID.fig'])
        close gcf;

        % Save best fits
        save([savePath data.runName '.mat'], 'LO_out', 'HI_out')

        disp(['Zoomed fits saved to ' savePath]);
        
    end

end


% ----------------------------------------------------------------------------------
% Code used to configure the input/output structure has been placed in this function 
% to make the main function more readable. It differs from that in FIT_prelim.
% ----------------------------------------------------------------------------------
function out = configure_options(out)

    % Clear previous D value
    out.vars.D = [];

    % Update grid options used in preliminary fits
    list_fc = out.vars.gridVars.listX;
    list_b = out.vars.gridVars.listY;
    [~, idx_b] = min(abs(log(list_b)-log(out.vars.b)));
    idxMin_b = max(idx_b-1, 1);
    idxMax_b = min(idx_b+1, numel(list_b));
    [~, idx_fc] = min(abs(list_fc-out.vars.fc));
    idxMin_fc = max(idx_fc-1, 1);
    idxMax_fc = min(idx_fc+1, numel(list_fc));
    out.vars.gridVars.minX = list_fc(idxMin_fc);
    out.vars.gridVars.maxX = list_fc(idxMax_fc);
    out.vars.gridVars.halfwidthX = 3;
    out.vars.gridVars.minY = list_b(idxMin_b);
    out.vars.gridVars.maxY = list_b(idxMax_b);
    out.vars.gridVars.disableZoom = false;
    out.vars.gridVars.halfwidthY = 3;

end
