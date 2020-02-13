Each file in this directory contains data for one example level series (a.k.a., one run). The example for Figure 2 of the manuscript is shown below with comments.

The 'data' structure contains the following:

% Whether the recording is 'tone' or 'spont' activity:
  type: 'tone'
% The name of the level series:
  runName: 'A6-U31-R1'
% The CF of the fiber:
  unitCF: 1300
% The stimulus frequency:
  f1: 1300
% The duration of each tone burst in milliseconds:
  toneDuration_ms: 100
% The rise/fall duration of each tone burst:
  toneRiseTime_ms: 4.250000000000000
% The rise/fall function used (here, 'cosine' means a cosine-squared function):
  toneRiseFun: 'cosine'
% The octaves of f1 away from the CF:
  toneOctavesFromCF: 0
% The duration of each repetition in milliseconds:
  repSpacing_ms: 250
% The vector strength for each stimulus level in the series:
  VS: [1×17 double]
% The time step of the recording in milliseconds
  dt_ms: 1.000000000000000e-03
% The spontaneous spike rate
  RspontSpike: 62.039999999999999
% The dB SPL for each stimulus level in the series
  toneDB: [16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80]
% The amplitude in pascals for each stimulus level in the series
  tonePa: [1×17 double]
% The number of repetitions for each stimulus level in the series
  nReps: [100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100]
% A structure containing the period histograms for each level in the series
  phist: [1×1 struct]

The 'phist' structure contains the following:

% The time vector for the period histogram in milliseconds
  t_ms: [1×769 double]
% The rate of release events for the period histogram, where each row is one stimulus level. All period histograms have the phase angle of the mean vector aligned to pi.
  Revent_per_pressure: [17×769 double]
% The number of events per bin, where all stimulus levels are concatenated one after another (this could be easily 'reshaped' to match Revent_per_pressure, if desired):
  Nevent_concatenated: [13073×1 double]
% The number of complete cycles used from each stimulus repetition
  cyclesPerRep: 117