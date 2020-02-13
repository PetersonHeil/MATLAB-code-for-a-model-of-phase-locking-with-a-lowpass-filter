% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% This function sets up the grid using the options specified in gridVars. 
% This function will take care of all details related to zooming in or recentering 
% the grid.
function gridVars = FIT_getNextGrid(gridVars)
   
    % Check whether this is the first grid in the current fit. Here, the first grid
    % is NOT synonymous with the preliminary grid, but really the first grid of each
    % round of fitting. That means the grid for the 'PRELIM' fits AND the initial 
    % grid for the 'ZOOMED' fits are BOTH considered 'first' grids.
    isFirstGrid = ~all(isfield(gridVars, {'gridError', 'gridX', 'gridY'}));

    if isFirstGrid
        disp('First grid.')
        gridVars = calcLists(gridVars);
    else
        gridVars.prevGridX = gridVars.gridX;
        gridVars.prevGridY = gridVars.gridY;
        gridVars.prevGridError = gridVars.gridError;

        [~, idxBest] = min(gridVars.gridError(:));
        [idxBestRow, idxBestCol] = ind2sub(size(gridVars.gridError), idxBest);
        isOnLeftEdge = (idxBestCol == 1);
        isOnRightEdge = (idxBestCol == numel(gridVars.listX));
        isOnBottomEdge = (idxBestRow == 1);
        isOnTopEdge = (idxBestRow == numel(gridVars.listY));
        isOnEdgeOfSpace = isOnLeftEdge || isOnRightEdge || isOnBottomEdge || isOnTopEdge;

        if isOnEdgeOfSpace
            gridVars.factorX = gridVars.listX(2)./gridVars.listX(1);
            gridVars.factorY = gridVars.listY(2)./gridVars.listY(1);
            
            if isOnLeftEdge
                gridVars.maxX = gridVars.listX(2);
                gridVars.minX = gridVars.maxX/(gridVars.factorX^(gridVars.halfwidthX*2));
            end
            if isOnRightEdge
                gridVars.minX = gridVars.listX(end-1);
                gridVars.maxX = gridVars.minX*(gridVars.factorX^(gridVars.halfwidthX*2));
            end
            if isOnBottomEdge
                gridVars.maxY = gridVars.listY(2);
                gridVars.minY = gridVars.maxY/(gridVars.factorY^(gridVars.halfwidthY*2));
            end
            if isOnTopEdge
                gridVars.minY = gridVars.listY(end-1);
                gridVars.maxY = gridVars.minY*(gridVars.factorY^(gridVars.halfwidthY*2));
            end

            if gridVars.maxX > gridVars.ubX
                % Reduce x to ub if it exceeds it!
                gridVars.maxX = gridVars.ubX;
                if ~(isOnTopEdge||isOnBottomEdge)
                    % Shrink y grid
                    gridVars.minY = gridVars.listY(idxBestRow)./gridVars.factorY;
                    gridVars.maxY = gridVars.listY(idxBestRow).*gridVars.factorY;
                end
            end
            if gridVars.minX < gridVars.lbX
                % Increase x to lb if it exceeds it!
                gridVars.minX = gridVars.lbX;
                if ~(isOnTopEdge||isOnBottomEdge)
                    % Shrink y grid
                    gridVars.minY = gridVars.listY(idxBestRow)./gridVars.factorY;
                    gridVars.maxY = gridVars.listY(idxBestRow).*gridVars.factorY;
                end
            end
            if gridVars.maxY > gridVars.ubY
                % Reduce y to ub if it exceeds it!
                gridVars.maxY = gridVars.ubY;
                if ~(isOnLeftEdge||isOnRightEdge)
                    % Shrink x grid
                    gridVars.minX = gridVars.listX(idxBestCol)./gridVars.factorX;
                    gridVars.maxX = gridVars.listX(idxBestCol).*gridVars.factorX;
                end
            end
            if gridVars.minY < gridVars.lbY
                % Increase y to lb if it exceeds it!
                gridVars.minY = gridVars.lbY;
                if ~(isOnLeftEdge||isOnRightEdge)
                    % Shrink x grid
                    gridVars.minX = gridVars.listX(idxBestCol)./gridVars.factorX;
                    gridVars.maxX = gridVars.listX(idxBestCol).*gridVars.factorX;
                end
            end
            disp('Sitting on edge of parameter space. Recentering grid.')
            gridVars = calcLists(gridVars);
        else
            disp('Sitting within parameter space. Shrinking grid.')

            if numel(gridVars.listX) == 3
                gridVars.minX = geomean(gridVars.listX(1:2));
                gridVars.maxX = geomean(gridVars.listX(2:3));
            else
                gridVars.factorX = gridVars.listX(2)./gridVars.listX(1);
                gridVars.minX = gridVars.listX(idxBestCol)./gridVars.factorX;
                gridVars.maxX = gridVars.listX(idxBestCol).*gridVars.factorX;
            end

            if numel(gridVars.listY) == 3
                gridVars.minY = geomean(gridVars.listY(1:2));
                gridVars.maxY = geomean(gridVars.listY(2:3));
            else
                gridVars.factorY = gridVars.listY(2)./gridVars.listY(1);
                gridVars.minY = gridVars.listY(idxBestRow)./gridVars.factorY;
                gridVars.maxY = gridVars.listY(idxBestRow).*gridVars.factorY;
            end

            gridVars.factorX = [];
            gridVars.factorY = [];
            
            gridVars = calcLists(gridVars);
            if any(~diff(gridVars.listX)) || any(~diff(gridVars.listY))
                error('ERROR: stuck in an unexpected loop!')
            end
            
        end
    end

    [gridVars.gridX, gridVars.gridY] = meshgrid(gridVars.listX, gridVars.listY);

    % Check if termination criteria have been met
    if (gridVars.factorX<gridVars.factorXcriterion) && (gridVars.factorY<gridVars.factorYcriterion)
        gridVars.unfinished = false;
        disp('Grid is small enough to meet termination criterion. Fitting terminated.')        
    else
        gridVars.unfinished = true;
        gridVars.gridError = nan(size(gridVars.gridX));
        gridVars.gridD = nan(size(gridVars.gridX));
    end

end


% ----------------------------------------------------------------------------------
% This function calculates the values of X and Y for the grid
% ----------------------------------------------------------------------------------
function gridVars = calcLists(gridVars)

    areExtremaProvided = all(isfield(gridVars, {'minX' 'maxX' 'minY' 'maxY'}));
    if ~areExtremaProvided
        gridVars.minX = gridVars.centerX/(gridVars.factorX^gridVars.halfwidthX);
        gridVars.maxX = gridVars.centerX*(gridVars.factorX^gridVars.halfwidthX);
        gridVars.minY = gridVars.centerY/(gridVars.factorY^gridVars.halfwidthY);
        gridVars.maxY = gridVars.centerY*(gridVars.factorY^gridVars.halfwidthY);
    end

    gridVars.listX = logspace(log10(gridVars.minX), log10(gridVars.maxX), gridVars.halfwidthX*2+1);
    gridVars.listY = logspace(log10(gridVars.minY), log10(gridVars.maxY), gridVars.halfwidthY*2+1);

    if ~isfield(gridVars, 'factorX') || ~isfield(gridVars, 'factorY') || isempty(gridVars.factorX) || isempty(gridVars.factorY)
        gridVars.factorX = gridVars.listX(2)./gridVars.listX(1);
        gridVars.factorY = gridVars.listY(2)./gridVars.listY(1);
    end
    
    if any(~diff(gridVars.listX)) || any(~diff(gridVars.listY))
        warning('Stuck in a loop! Attempting to randomly jostle out of it!')
        
        gridVars.minX = 1+rand();
        gridVars.maxX = 1+10000*rand();
        gridVars.minY = 1+rand();
        gridVars.maxY = 1+10000*rand();        
        gridVars = calcLists(gridVars);        
    end

end
