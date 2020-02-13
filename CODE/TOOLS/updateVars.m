% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function takes a structure of default/original values and updates it
% based on the key-value pairs or struct specified in varargin.
% ----------------------------------------------------------------------------------
function vars = updateVars(defaults, varargin)

    % Get the input values supplied
    inputs = getVars(varargin);

    % Determine which vars have been supplied
    if ~isempty(inputs); inputKeys = fieldnames(inputs);
    else; inputKeys = []; end

    % Overwrite defaults with supplied values
    for i = 1:numel(inputKeys)
        defaults.(inputKeys{i}) = inputs.(inputKeys{i});
    end
    
    % Return the overwritten defaults
    vars = defaults;

end