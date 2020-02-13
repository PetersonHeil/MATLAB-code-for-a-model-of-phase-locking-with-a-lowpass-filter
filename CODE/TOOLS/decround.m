% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% Function that rounds the input to the nearest specified decimal value.
% For example, decround(100.126, 1) will return 100
%              decround(100.126, 0.1) will return 100.1
%              decround(100.126, 0.01) will return 100.13
% You can also specify to round up or round down. 
% For example, decround(100.126, 1, @ceil) will return 101
%              decround(100.126, 0.1, @ceil) will return 100.2
%              decround(100.126, 0.01, @floor) will return 100.12
% ----------------------------------------------------------------------------------
function vals = decround(vals, dec, roundFunction)
    if ~exist('roundFunction','var')
        roundFunction = @round;
    end
    if ~isa(roundFunction,'function_handle')
        roundFunction = eval(['@' roundFunction]);
    end
    roundFactor = 1/dec;
    vals = roundFunction(roundFactor*vals)/roundFactor;
end
