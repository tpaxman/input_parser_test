% I have a set of functions that takes a cell array of tables and plots data from each
% table as a subplot on a figure.  I have been learning to use the `inputParser` class 
% to handle `varargin` inputs, and have that here. The optional parameters are for 
% choosing plot type (`plot` or `bar`) and for choosing the names of the variables to 
% plot from the input tables.

% In my scenario, the inputs need to be passed along about 3 functions deep, 
% so I'm wondering about best practices for doing this. In my current setup, 
% the outermost function (`main`) takes a `varargin` input and parses the inputs 
% by assigning defaults and such.  Then I'm wondering, when it comes time to pass these 
% inputs to the next function, is it best to pass the `parsedInputs` data Results struct 
% down the line, or is it better to have the next function also take a `varargin` argument 
% and to repeat the parsing process again? I'm not sure what the best way to go about this
% is. My code is below. The main script for test purposes looks as follows:

    % RUN TEST CASE
    Tables{1} = table([1 2 3]' , [6 7 8]', 'VariableNames', {'diam', 'length'});
    Tables{2} = table([1 2 6]' , [6 9 2]', 'VariableNames', {'diam', 'length'});
    Tables{3} = table([3 9 11]', [7 4 1]', 'VariableNames', {'diam', 'length'});
    main(Tables);

% The main function takes a (required) cell array of tables (`Tables`) and variable 
% argument parameters, such as `'xVariable'`, `'yVariable'`, `'plotType'`. 

    function main(Tables, varargin)%PlotParams, DICTS)
      % parse inputs
      parsedInputs = parse_plot_inputs(Tables, varargin);
      
      % create figure of subplots
      figure;  
      make_subplots_from_tables(parsedInputs);
    end

% A `parse_plot_inputs` function takes care of the default value assignment, etc.:

    function parsedInputs = parse_plot_inputs(Tables, vararginList)
    % input parser function for this specific plotting case
      p = inputParser;
      addRequired(p,  'Tables', @iscell);
      addParameter(p, 'xVariable', 'diam');
      addParameter(p, 'yVariable', 'length');
      addParameter(p, 'plotType', 'plot');
      parse(p, Tables, vararginList{:});
      parsedInputs = p;
    end

% `make_subplots_from_tables` then loops through the cell array of tables, and calls 
% `plot_special` to plot each of them on its own subplot.

    function make_subplots_from_tables(parsedInputs) 
      
      % unpack parsed inputs
      Tables = parsedInputs.Results.Tables;

      % plot each table as a subplot
      numTables = length(Tables);
      for i = 1:numTables      
          subplot(numTables, 1, i); hold on;
          plot_special(Tables{i}, parsedInputs)
      end
    end

% `plot_special` is the "base" function in this scenario that calls the MATLAB plot functions:
    
    function plot_special(T, parsedInputs)

      % unpack parsed inputs
      xVariable = parsedInputs.Results.xVariable;
      yVariable = parsedInputs.Results.yVariable;
      plotType  = parsedInputs.Results.plotType;

      % plot single table on one plot
      xVals = T.(xVariable);
      yVals = T.(yVariable);
      switch plotType
        case 'plot'
          plot(xVals, yVals, '-x');
        case 'bar'
          bar(xVals, yVals);
        otherwise
          error('invalid plot type');
      end
    end

% I am unsure whether this is the best method for taking in arguments and for using them in subsequent functions.  This method works, although I'm not sure that it's the best practice, nor the most flexible, for example, considering the scenario when I would like to use plot_special on its own, and would like to be able to pass it arguments for `xVariable`, `yVariable`, etc. if need be.  Given that it is currently dependent on the `parsedInputs` list from the `main` function, that wouldn't be doable.  However, I'm unsure what another way to define it would be. I considered having an `if` statement built in along with a `varargin` input argument that checks whether the varargin is an already-parsed struct, or if it's getting the variables directly and needs to call the `parse_plot_inputs` itself to get things working.  Any advice would be great.
