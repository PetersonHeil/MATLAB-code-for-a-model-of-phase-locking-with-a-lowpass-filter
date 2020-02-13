% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This script can be used to quickly generate model functions for a given set of 
% model parameters. There is no data fitting performed here.

% Check that the current directory is valid
if ~exist(fullfile(cd, 'DEMO_MODEL.m'), 'file')
    error('The current directory must be set to the one which contains the file DEMO_MODEL.m')
else
    % restoredefaultpath()
    addpath(genpath('CODE'))
end

% The structure 'out' stores nearly everything we care about: computed model 
% functions, fit results, etc. The name 'out' is something of a misnomer, because 
% also stores all inputs (i.e., the model parameter values specified below).
out = [];

% Define model parameters
out.vars.M0 = 0.45;
out.vars.b = 2006.6385;
out.vars.fc = 1071.5;
out.vars.D = 5.48421;

% Define parameters specifying properties of stimulus, ANF, and filtering
out.vars.dt_ms = 0.001;
out.vars.tMax_ms = 100; % Duration of signal to be lowpass filtered; the centermost cycle of the output will be retained
out.vars.order = 3;
out.vars.f1 = 1300;
out.vars.tonePa = db2pa(16:4:80);
out.vars.RspontEvent = 67.03;

% Compute MET currents and lowpass filter outputs (results saved to 'out.model')
out = MODEL_MET_LPF(out);

% Compute rates of synaptic release events (results saved to 'out.model')
out = MODEL_Rate(out);

% Plot model results
PLOT_demo(out)



