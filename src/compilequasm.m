function S = compilequasm(filename, gateset)
    % Builds the superoperator corresponding to the quasm code in the filename
    % using gates from gatset
    %
    % Arguments:
    %	- filename:		A string containing the path to the quasm file on disk
    %	- gateset:		A struct containing at least the gates used in the
    %					quasm file. The gates should be SuperOp instances
    %
    % Outputs:
    %	- S:			The SuperOp corresponding to the final built gate
    %	
    %
    % Usage Example:
    %

    %--------------------------------------------------------------------------
    % © 2014 Ian Hincks (ian.hincks@gmail.com).
    % 
    % This file is a part of the quantum-utils-matlab project.
    % Licensed under the AGPLv3.
    %--------------------------------------------------------------------------
    % This program is free software: you can redistribute it and/or modify
    % it under the terms of the GNU Affero General Public License as published
    % by the Free Software Foundation, either version 3 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU Affero General Public License for more details.
    %
    % You should have received a copy of the GNU Affero General Public License
    % along with this program.  If not, see <http://www.gnu.org/licenses/>.
    %--------------------------------------------------------------------------


	
	% first we read through each line of the file and put the info into the
	% struct array gatedescription
	fid = fopen(filename);
	
	maxindex = 0;
	gatedescription = {};
	numqubits = 0;
	
	% loop through each line and parse it. store the results in
	% gatedescription
	linecounter = 1;
	line = fgetl(fid);
	while ischar(line)
		
		if ~isempty(line) && line(1) ~= '%' && line(1) ~= '#'
		
			parsedline = textscan(line, '%s');
			parsedline = parsedline{1};
			
			gatestring = parsedline{1};
			if ~isnan(str2double(gatestring))
				warning('First word of a line is expected to be a string. Ignoring line %d: "%s".', linecounter, line);
			elseif strcmpi(gatestring, '.numqubits')
				numqubits = str2double(parsedline{2});
			elseif ~isfield(gateset, gatestring)
				warning('The gate "%s" was not found in the gateset. Ignoring line %d: "%s".', gatestring, linecounter, line);
			else
			
				% notice that we add one because the quasm qubits positions
				% are 0-indexed
				indeces = cellfun(@str2double, parsedline(2:end))+1;
				maxindex = max([maxindex; indeces]);
				
				gatedescription{end+1}.gatestring = gatestring;
				gatedescription{end}.indeces = indeces;
			end
		
		end
		
		line = fgetl(fid);
		linecounter = linecounter + 1;
	end
	
	fclose(fid);
	
	% make the number of qubits maxindex if the file did not specify
	if numqubits <= 0
		numqubits = maxindex;
	end

	% the dimension of each factor space (all qubits)
	dimsout = 2*ones(1,numqubits);
	
	% now loop through the gate descriptions and fill them in using
	% extendgate, which does all of the hard work of this function
	S = eyeSO(2^numqubits);
    dispwait = (numqubits >= 5);
    if dispwait
        h = waitbar(0, 'Compiling...');
        gates_done = 0;
        n_gates = length(gatedescription);
    end
    
	for gate = gatedescription
	    G = gate{1};
	    S = [extendgate(gateset.(G.gatestring), dimsout, G.indeces) S];
        if dispwait
            gates_done = gates_done + 1;
            waitbar(h, gates_done / n_gates);
        end
    end
	
end
