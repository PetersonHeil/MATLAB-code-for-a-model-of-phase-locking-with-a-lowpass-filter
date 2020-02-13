% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This script can be used to start the grid-based fitting procedure as used in the 
% manuscript. Despite the reasonably optimized grid-based approach, this will take 
% several hours (or more) to finish for all example data and M0 values.

% Check that the current directory is valid
if ~exist(fullfile(cd, 'DEMO_FITTING.m'), 'file')
    error('The current directory must be set to the one which contains the file DEMO_FITTING.m')
else
    % restoredefaultpath()
    addpath(genpath('CODE'))
end

% Name of subfolder where the fit results should be saved in the 'FITS' directory
saveName = 'DEMO LEVEL SERIES';

% List of data to fit (options are those used in Figures 2-5 and 8 of the manuscript)
data_to_fit = {
    'Fig2Data.mat'      % A6-U31-R1
    'Fig3Data.mat'      % A7-U10-R2
    'Fig4Data.mat'      % A7-U20-R1
    'Fig5Data.mat'      % A2-U14-R1
    'Fig8AData.mat'     % A3-U8-R1
    'Fig8BData.mat'     % A3-U43-R4
    'Fig8CData.mat'     % A5-U40-R2
    };

% List of M0 values to compute fits for (this value is fixed to each of the values
% listed here, and the other parameters are systematically fitted). M0 is the 
% normalized MET current at rest (i.e., the resting open probability of MET channels)
M0_list = 0.05:0.05:0.95;

% Loop through each data file specified
for i=1:numel(data_to_fit)
	load(['DATA\' data_to_fit{i}])
    disp(['Data loaded from ' data_to_fit{i}]);

    % Loop through each M0 specified
    for m = 1:numel(M0_list)

            % Perform preliminary fits using a large initial grid of b and fc
            FIT_prelim(data, M0_list(m), saveName);

            % Perform fits while progressively zooming in near the minimum
            FIT_zoomed(data, M0_list(m), saveName);

    end

    % Clear data that was just fitted
    clear data;

end

% Compare all results and generate summary figures
PLOT_population_figures(saveName);
