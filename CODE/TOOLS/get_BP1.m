% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function get the equivalent B*P1 value for a given vector strength, under the 
% assumption that the period histogram is described by a single cycle of a sinusoid
% passed through an exponential transfer function (as in Peterson and Heil, 
% J Neurosci 2019). Here, B is the scale factor of the exponential transfer function 
% and P1 is the tone amplitude in pascals.
% ----------------------------------------------------------------------------------
function BP1 = get_BP1(VS)

    if VS>0.9993
        error('VS > 0.9992 is not supported!')
    end
    
    if VS<5e-6
        error('VS < 0.000005 is not supported!')
    end
    
    X_BP1_list = logspace(log10(1e-5), log10(1e3), 1000000);
    Y_VS_list = besseli(1,X_BP1_list)./besseli(0,X_BP1_list);

    idxInclude = ~isnan(Y_VS_list);
    X_BP1_list(~idxInclude) = [];
    Y_VS_list(~idxInclude) = [];

    BP1 = interp1(Y_VS_list,X_BP1_list,VS);

end