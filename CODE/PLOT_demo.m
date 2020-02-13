% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function plots the results of the fitting
% ----------------------------------------------------------------------------------
function PLOT_demo(out)

    out.vars.goalMeanPhasePt = pi;
    out.vars.goalMeanPhaseRate = pi;
    out = MODEL_MET_LPF(out);
    out = MODEL_Rate(out);

    figure();
    sub = subplotter();
    sub.add(1,1,'size',[820 100]);
    sub.add(1,2,'size',[225 225]);
    sub.add(2,1,'size',[225 225], 'halign', 'right');
    sub.add(2,2,'size',[225 225]);
    sub.build();

    % Plot the period histograms and model fits for the level series
    sub.select(1,1); hold all;
    PLOT_demo_level_series(out, gca);

    % Plot the "overall" transfer functions for the level series
    sub.select(1,2); hold all;
    PLOT_demo_transfer_functions(out, gca)

    % Plot the "overall A"-versus-level function and the "overall B"-versus-level 
    % function for the level series, including extrapolations to high and low levels
    PLOT_demo_overall_A_and_B(out, sub);

end
