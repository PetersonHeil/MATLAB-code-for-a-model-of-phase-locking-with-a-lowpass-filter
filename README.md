# Model of ANF phase locking with lowpass filter
MATLAB code for the model and fitting procedure used in the manuscript of 
Peterson and Heil submitted to The Journal of Neuroscience on 13 February 2020.

------------------------------------------------------------------------------------
Contents:
------------------------------------------------------------------------------------
(1) The 'CODE' directory contains files for the model and fitting procedure.
    Files related to the model are prefixed with 'MODEL'.
    Files related to plotting are prefixed with 'PLOT'.
    Files related to the fitting procedure are prefixed with 'FIT'.
    Files for other tasks, mostly related to plotting, calculating, and checking 
        inputs are in the 'TOOLS' subdirectory.
(2) The 'DATA' directory contains example data from Figures 2-5 in the study.
(3) The 'FITS' directory contains fit results and summary figures.
(4) DEMO_FITTING.m can be used to start the grid-based fitting procedure as used
		in the manuscript.
(5) DEMO_MODEL.m can be used to quickly generate model functions for a given 
		set of model parameters.

------------------------------------------------------------------------------------
Fits are performed in two rounds: 
------------------------------------------------------------------------------------
(1) A preliminary fit using a large grid of fc (the cutoff frequency) and b (the 
	slope factor of the Boltzmann transducer function). The grid's properies are 
	specified in the subfunction 'configure_options' at the bottom of FIT_prelim.m
(2) A second fit which successively zooms in on the grid region with the minimum 
	error. The grid's properies are specified in the subfunction 'configure_options' 
	at the bottom of FIT_zoomed.m

NOTE: This code makes use of the MATLAB function 'fmincon', which is part of the 
Optimization Toolbox. If this toolbox is not installed, you will need to replace 
'fmincon' in 'FIT_getBestD.m' by a different optimization function. You will also
need to update the options set defined in 'FIT_prelim.m' so it is compatible with
whatever optimization function you decide to use. Changing the solver is likely to
somewhat affect the parameter estimates obtained, but it should give very
similar values.
