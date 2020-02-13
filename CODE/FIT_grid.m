% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% The function which systematically checks each pair of grid values to identify
% which yields the best fit results. Obtains the overall best b, fc, D, and error.
% The function also plots the grid to the axis specified by hAxes.
% ----------------------------------------------------------------------------------
function out = FIT_grid(out, hAxes)

    % Select the axis provided and add a title
    set(gcf,'CurrentAxes',hAxes)
    title(out.data.runName)
    hold all;

    % If errors and D values exist from previous (i.e., prelim) fits, delete them
    if isfield(out.vars.gridVars, 'gridError')
        out.vars.gridVars = rmfield(out.vars.gridVars, 'gridError');
        out.vars.gridVars = rmfield(out.vars.gridVars, 'gridD');
    end

    % Construct the grid using the current specifications
    gridVars = FIT_getNextGrid(out.vars.gridVars);
    nParams = numel(gridVars.gridX);

    % Initialize results to empty matrices, as we don't know in advance how large
    % these will need to be.
    allX = [];
    allY = [];
    allB = [];
    allError = [];
    
    % We will always save the 'out' structure for the best fit so far. Initialize empty.
    best_out = [];

    while gridVars.unfinished
        for iParam = 1:nParams

            % Estimate intitial cutoff
            out.vars.fc = gridVars.gridX(iParam);
            out.vars.b = gridVars.gridY(iParam);

            out = MODEL_MET_LPF(out);

            % Roughly assign an initial guess for D. This doesn't matter much;
            % the optimization function (fmincon) should find the optimum value
            % easily because D is the only free parameter!
            if out.vars.RspontEvent
                out.vars.D = 10*out.vars.RspontEvent^(-0.2);
            else
                out.vars.D = 100;
            end

            % Specify free parameter name and bounds
            out.vars.paramNames = {'D'};
            out.vars.lb = 0.01;
            out.vars.ub = 1000;

            % Perform optimization to obtain D value
            out = FIT_getBestD(out);

            % Save D value and corresponding error
            gridVars.gridD(iParam) = out.fit.D;
            gridVars.gridError(iParam) = out.fit.error;

            % If the fit for the current grid point is the best one so far, 
            % save the results (e.g., 'out') and the index
            if iParam == 1 || (out.fit.error == min(min(gridVars.gridError)))
                best_out = out;
                idxBest = iParam;
            end

            disp(['Fitting grid point ', num2str(iParam), ' of ', num2str(nParams)])
        end

        % Now that the entire grid is complete, save the overall best grid point and error
        gridVars.bestX = gridVars.gridX(idxBest);
        gridVars.bestY = gridVars.gridY(idxBest);
        gridVars.bestError = gridVars.gridError(idxBest);

        % Replace last-defined 'out' with the best 'out'
        out = best_out;

        % Plot the grid results...
        delete(get(gca,'Children'));
        set(gca,'XScale','log')
        set(gca,'YScale','log')
        xlabel('Cutoff frequency fc (Hz)');
        ylabel('Boltzmann slope factor b (1/Pa)');
        view(2)
        axis tight
        drawnow()

        allX = [allX; gridVars.gridX(:)]; %#ok<*AGROW>
        allY = [allY; gridVars.gridY(:)];
        allB = [allB; gridVars.gridD(:)];
        allError = [allError; gridVars.gridError(:)];

        scatter(allX, allY, 30, allError, 'fill')
        set(gca,'XScale','log')
        set(gca,'YScale','log')
        set(gca,'CLim',[min(allError) min(allError)*1.5]);
        axis tight;
        hold all;

        % Set fc tick marks
        fTicks = sort([xlim geomean(xlim)]);
        fTicks = sort([fTicks geomean(fTicks(1:2)) geomean(fTicks(2:3))]);
        fTickLabels = round(fTicks);
        set(gca,'XTick',(fTicks));
        set(gca,'XTickLabels',(fTickLabels));

        % Place a pink square behind all points within 5% of the minimum error for this grid
        isNearMinimum = allError<min(allError)*1.05;
        hNearMinimum = plot3(allX(isNearMinimum), allY(isNearMinimum), -ones(sum(isNearMinimum),1), 'square', 'Color', [1 0.8 0.8], 'LineWidth', 5);
        uistack(hNearMinimum,'bottom');

        % Draw a red circle around the point yielding the minimum error for this grid
        isAtMinimum = allError==min(allError);
        hAtMinimum = plot3(allX(isAtMinimum), allY(isAtMinimum), ones(sum(isAtMinimum),1), 'o', 'Color', [1 0 0], 'LineWidth', 2);
        uistack(hAtMinimum,'top');

        drawnow();

        % Determine whether to keep zooming
        if gridVars.disableZoom
            % Do not zoom at all if zooming has been disabled...
            gridVars.unfinished = false;
        else
            % ... otherwise compute the next grid. If the termination criteria 
            % have been met, this function will set gridVars.unfinished to false.
            gridVars = FIT_getNextGrid(gridVars);
        end

    end

    % Save final gridVars
	out.vars.gridVars = gridVars;

end
