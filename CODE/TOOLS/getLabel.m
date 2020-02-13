

function label = getLabel(varargin)

    args = varargin;

    % Wrap any bare strings with a cell, convert any matrixes to char cells
    for i=1:nargin
        if ischar(args{i})
            args{i} = args(i);
        end
        if isnumeric(args{i})
            args{i} = num2cell(args{i});
            args{i} = cellfun(@num2str, args{i}, 'UniformOutput', false);
        end
    end

    nElements = cellfun(@numel, args);

    % Duplicate elements as needed
    for i=1:nargin
        if nElements(i) == 1
            args{i}(1:max(nElements)) = args{i};
        end
    end

    % Perform concatenation of all elements for each legend portion
    label = cell(1, max(nElements));
    for i=1:max(nElements)
        for j=1:nargin
            label{i} = [label{i} args{j}{i}];
        end
    end

end