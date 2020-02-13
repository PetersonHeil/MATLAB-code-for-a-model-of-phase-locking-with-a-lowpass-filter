% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function is responsible for coordinating the preliminary round of fits.
% ----------------------------------------------------------------------------------
function FIT_prelim(data, M0, saveName)

    % Define save path and create save directory
    savePath = ['FITS\' saveName ' (PRELIM)\M0=' num2str(M0) '\' data.runName '\'];

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
    LO_out = [];
    LO_out = configure_options(LO_out, data, M0, 'LO');

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
    HI_out = [];
    HI_out = configure_options(HI_out, data, M0, 'HI');

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

    disp(['Preliminary fits saved to ' savePath]);
    
end


% ----------------------------------------------------------------------------------
% Code used to configure the input/output structure has been placed in this function 
% to make the main function more readable.
% ----------------------------------------------------------------------------------
function out = configure_options(out, data, M0, LO_or_HI)

        % Store data for the current run
        out.data = data;

        % Define options for the stimulus
        out.vars = [];                                                              % Structure containing...
        out.vars.dt_ms = data.dt_ms;                                                % ... time step for simulation (in ms)
        out.vars.order = 3;                                                         % ... order of the lowpass filter
        out.vars.tonePa = data.tonePa;                                              % ... stimulus amplitude (in pascals)
        out.vars.f1 = data.f1;                                                      % ... stimulus frequency (in hertz)
        out.vars.tMax_ms = 100;                                                     % ... stimulus duration for simulation (in ms)
        out.vars.theta0 = 0;                                                        % ... stimulus phase shift for simulation (in radians)

        % Define fixed model options
        out.vars.RspontEvent = 1000/(1000/out.data.RspontSpike - 0.6 - 0.6);        % ... spontaneous event rate (in events/s)
        out.vars.M0 = M0;                                                           % ... normalized MET current at rest (i.e., resting open probaiblity)
        out.vars.goalMeanPhaseMET = pi/2;                                           % ... phase to align mean phase of MET output (in radians)
        out.vars.goalMeanPhaseLPF = pi/2;                                           % ... phase to align mean phase of LPF outout (in radians)
        out.vars.goalMeanPhaseRate = pi;                                            % ... phase to align mean phase of Rate outout (in radians)
        
        % Define options for fitting procedure
        out.vars.errorToMinimize = 'NLOGL';                                         % ... type of error to use in fitting
        out.vars.paramNames = 'D';                                                  % ... name of free parameter to fit with fmincon
        out.vars.lb = 0.1;                                                          % ... lower bound of the free parameter
        out.vars.ub = 100;                                                          % ... upper bound of the free parameter
        out.vars.options = optimoptions('fmincon', ...                              % ... fmincon options
            'Algorithm', 'interior-point',... 
            'StepTolerance', 1e-10, ...
            'FunctionTolerance', 1e-10, ...
            'OptimalityTolerance', 1e-10);
        
        % Define grid options
        out.vars.gridVars.minY = 1;                                                 % ... minimum value of Y in next grid
        out.vars.gridVars.maxY = 100000;                                            % ... maximum value of Y in next grid
        out.vars.gridVars.lbY = 1;                                                  % ... minimum possible value of Y, even if grid expands beyond previous values
        out.vars.gridVars.ubY = 100000;                                             % ... maximum possible value of Y, even if grid expands beyond previous values
        out.vars.gridVars.disableZoom = true;                                       % ... determines whether to terminate withhout zooming in
        out.vars.gridVars.halfwidthX = 15;                                          % ... the number of X values on either side of the center value (total number = halfwidthX*2+1)
        out.vars.gridVars.halfwidthY = 15;                                          % ... the number of Y values on either side of the center value (total number = halfwidthX*2+1)
        out.vars.gridVars.factorXcriterion = 1.01;                                  % ... criterion which determines when to stop zooming in X dimension (1.01 means stop when parameter changes by less than 1% each step)
        out.vars.gridVars.factorYcriterion = 1.01;                                  % ... criterion which determines when to stop zooming in Y dimension (1.01 means stop when parameter changes by less than 1% each step)
        
        % Set values which depend on whether we are sampling the LO or HI cutoff region
        switch LO_or_HI
            case 'LO'
                % Define options specific to the LO grid 
                out.vars.gridVars.minX = out.vars.f1/10;                        % ... minimum value of X in next grid
                out.vars.gridVars.maxX = out.vars.f1;                           % ... maximum value of X in next grid
                out.vars.gridVars.lbX = out.vars.f1/10;                         % ... minimum possible value of X, even if grid expands beyond previous values
                out.vars.gridVars.ubX = out.vars.f1;                            % ... maximum possible value of X, even if grid expands beyond previous values
            case 'HI'
                % Define options specific to the HI grid
                out.vars.gridVars.minX = out.vars.f1;                           % ... minimum value of X in next grid
                out.vars.gridVars.maxX = out.vars.f1*10;                        % ... maximum value of X in next grid
                out.vars.gridVars.lbX = out.vars.f1;                            % ... minimum possible value of X, even if grid expands beyond previous values
                out.vars.gridVars.ubX = out.vars.f1*10;                         % ... maximum possible value of X, even if grid expands beyond previous values              
            otherwise
                error('LO_or_HI must be either ''LO'' or ''HI''')
        end
end
