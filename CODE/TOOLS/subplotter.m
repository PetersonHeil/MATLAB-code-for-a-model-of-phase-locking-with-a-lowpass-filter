% Written by Adam J. Peterson (adam.peterson@lin-magdeburg.de)
% For the study by Peterson and Heil, submitted to J Neurosci on 13 February 2020.
% ----------------------------------------------------------------------------------

% An subplotter object can be used to easily customize subplot sizes,
% spacings, and alignments.

%-----------------------------------------------------------------------------------
% Creating a subplotter object
%-----------------------------------------------------------------------------------

% figure;
% sub = subplotter();

% OPTIONS:

% To control how much whitespace there is on the edge of the figure:
% 'bmargin' - the margin (in pixels) along the bottom edge of the figure
% 'tmargin' - the margin (in pixels) along the top edge of the figure
% 'lmargin' - the margin (in pixels) along the left edge of the figure
% 'rmargin' - the margin (in pixels) along the right edge of the figure

% To control how densely the panels are packed in the figure:
% 'vpadding' - the padding (in pixels) on either side of all panels 
% 'hpadding' - the padding (in pixels) on top and bottom of all panels

% Example:
% sub = subplotter('bmargin', 100, 'rmargin', 100, 'vpadding', 200);

%-----------------------------------------------------------------------------------
% Adding panels to the subplotter
%-----------------------------------------------------------------------------------

% sub.add(ROW,COL)

% OPTIONS:

% 'size' - the size of the panel in pixels [w h]
% 'halign' - horizontal alignment in case the panel is narrower than others in the column
% 'valign' - vertical alignment in case the panel is shorter than others in the row

%-----------------------------------------------------------------------------------
% Creating the figure
%-----------------------------------------------------------------------------------

% sub.build();

%-----------------------------------------------------------------------------------
% Selecting a panel
%-----------------------------------------------------------------------------------

% sub.select(ROW,COL);

%-----------------------------------------------------------------------------------
% Bringing it all together in one large example:
%-----------------------------------------------------------------------------------

% figure;
% sub = subplotter('bmargin', 100, 'rmargin', 100, 'vpadding', 200);
% sub.add(1,1,'size',[100 100]);                      
% sub.add(1,2,'size',[100 100]);                      
% sub.add(1,3,'size',[100 100]);                      
% sub.add(2,2,'size',[70 70], 'halign', 'center');
% sub.add(2,3,'size',[70 70], 'halign', 'right');
% sub.add(3,1,'size',[100 100], 'halign', 'left');
% sub.add(3,2,'size',[70 70], 'halign', 'center', 'valign', 'center');
% sub.add(3,3,'size',[70 70], 'halign', 'right', 'valign', 'bottom');
% sub.build()
% 
% x = 0:0.1:10;
% 
% sub.select(1,1); hold all;
% plot(x)
% 
% sub.select(1,2); hold all;
% plot(x, sin(x), '-g')
% 
% sub.select(2,2); hold all;
% plot(x, tan(x), '-k')
% 
% sub.select(3,1); hold all;
% plot(x, 1./x, '-r')
% sub.select(3,3); hold all;
% plot(x, exp(x))

% ----------------------------------------------------------------------------------
classdef subplotter < handle

    properties
        sizes = {};         % Stores specifications for each subplot
        subplots = [];      % Stores each subplot
        padding = [];       % Padding around subplot edges
        margin = [];        % Margin around figure edge
        units = [];         % Default unit is "pixels"
    end

    methods

        % =================================================================
        % Subplotter constructor
        % =================================================================
        function obj = subplotter(varargin)
            % Specify default values
            vars.vpadding = 80;                 % vertical
            vars.hpadding = 80;                 % horizontal
            vars.tmargin = 5;                   % top
            vars.bmargin = 5;                   % bottom
            vars.lmargin = 5;                   % left
            vars.rmargin = 5;                   % right
            vars.units = 'pixels';
            % Override defaults with varargin values
            vars = updateVars(vars, varargin);            
                        
            obj.padding.V = vars.vpadding;      % vertical
            obj.padding.H = vars.hpadding;      % horizontal
            obj.margin.T = vars.tmargin;        % top
            obj.margin.B = vars.bmargin;        % bottom
            obj.margin.L = vars.lmargin;        % left
            obj.margin.R = vars.rmargin;        % right
            obj.units = vars.units;
        end
  
        % =================================================================
        % Add a subplot to the group
        % =================================================================             
        function add(this, row, col, varargin)
            % Specify default values
            vars.size = [225 225];
            vars.valign = 'top';
            vars.halign = 'left';
            % Override defaults with varargin values
            vars = updateVars(vars, varargin);

            size.width = vars.size(1);
            size.height = vars.size(2);
            size.vertical = vars.valign;
            size.horizontal = vars.halign;
            this.sizes{row, col} = size;

        end

        % =================================================================
        % Select a subplot from the current layout
        % =================================================================             
        function select(this, row, col)
            subplot(this.subplots(row,col));
        end

        % =================================================================
        % Build the subplot objects that have been defined
        % =================================================================        
        function build(this)

            % Set figure units
            set(gcf, 'Units', this.units);

            % Count the rows and columns
            numRows = size(this.sizes,1);
            numCols = size(this.sizes,2);

            % Determine height of each row
            rowHeights = zeros(1,numRows);
            for row=1:numRows
                for col=1:numCols
                    if ~isempty(this.sizes{row,col})
                        rowHeights(row) = max(rowHeights(row), this.sizes{row,col}.height);                        
                    end
                end
            end

            % Determine width of each col
            colWidths = zeros(1,numCols);
            for col=1:numCols
                for row=1:size(this.sizes,1)
                    if ~isempty(this.sizes{row,col})
                        colWidths(col) = max(colWidths(col), this.sizes{row,col}.width);
                    end
                end
            end

            % Determine overall size of figure
            figWidth  = this.margin.L + (numCols+1)*this.padding.H + sum(colWidths)  + this.margin.R;
            figHeight = this.margin.B + (numRows+1)*this.padding.V + sum(rowHeights) + this.margin.T;
            this.resizeFigure(figWidth, figHeight);
            set(gcf,'Resize','off');

            % Build each subplot
            for row=1:size(this.sizes,1)
                for col=1:size(this.sizes,2)
                    if ~isempty(this.sizes{row,col})

                        % Get size of current subplot
                        plotSize = this.sizes{row,col};
                        plotWidth = plotSize.width;
                        plotHeight = plotSize.height;

                        % Determine position of subplot being selected,
                        % assuming vertical alignment is bottom and
                        % horizontal alignment is left
                        left =   this.margin.L + col*this.padding.H             + sum(colWidths(1:numCols < col));
                        bottom = this.margin.B + (numRows-row+1)*this.padding.V + sum(rowHeights(1:numRows > row));

                        % Adjust based on specified alignment
                        if strcmp(plotSize.horizontal, 'center');  left = left+(colWidths(col)-plotWidth)/2; end
                        if strcmp(plotSize.horizontal, 'right');   left = left+(colWidths(col)-plotWidth); end
                        if strcmp(plotSize.vertical, 'center');  bottom = bottom+(rowHeights(row)-plotHeight)/2; end
                        if strcmp(plotSize.vertical, 'top');     bottom = bottom+(rowHeights(row)-plotHeight); end

                        this.subplots(row,col) = subplot('position',[left/figWidth bottom/figHeight plotWidth/figWidth plotHeight/figHeight]);
                        set(gcf, 'PaperPositionMode', 'auto');
                        box on
                    end
                end
            end
        end
    end
    
    methods (Static)
        
        % =================================================================
        % Function to resize the current figure. Units are in whatever
        % unit type are default in the image.
        % =================================================================        
        function resizeFigure(width, height)

            % Set size of image            
            set(gcf,'Position',[0,0,width,height])             
            
        end
        
        % =================================================================
        % Function that places legend outside figure
        % =================================================================
        function placelegendEastOfPlot(hLegend, shiftInPixels)

            fPos = get(gcf, 'Position');
            lPos = get(hLegend, 'Position');
            lPos(1) = lPos(1)+lPos(3)+shiftInPixels/fPos(3);
            set(hLegend, 'Position', lPos);

        end

    end

end