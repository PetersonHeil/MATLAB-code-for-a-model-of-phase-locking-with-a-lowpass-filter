% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function computes the probability of observing x events for the 
% continuous poisson distribution with an expected (mean) number of events lambda
% ----------------------------------------------------------------------------------
function y = poisson(x, lambda)

    if numel(lambda) == 1
        lambda = repmat(lambda, 1, numel(x));
    end

    % Replace zero rates by very small rates
    lambda(lambda==0) = 1e-10;

    % Compute PDF
    y = exp(x .* log(lambda) - lambda - gammaln(x+1));

end