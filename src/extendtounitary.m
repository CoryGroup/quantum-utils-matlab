function U = extendtounitary(input,output)
    % Given two orthonormal sets of the same size, returns *a* unitary matrix
    % which maps the first set to the second.
    %
    % Arguments:
    %	- input:	A 2D matrix where the columns are orthonormal. Must have the
    %				same size as output.
    %	- output:	A 2D matrix where the columns are orthonormal. Must have
    %				the same size as input.
    %
    % Outputs:
    %	- U:		A unitary matrix U such that U*input(:,k) is equal to
    %				output(:,k) up to numerical error. This unitary is of
    %				course not unique.
    %	
    %
    % Usage Example:
    %
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



	if ~isnumeric(input) || ~isnumeric(output) || length(size(input)) ~=2 || length(size(output)) ~= 2
		error('Expecting "input" and "output" to be 2D arrays');
	end
	
	numvec = size(input,2);
	dim = size(input,1);
	
	if size(output,2) ~= numvec || size(output,1) ~= dim
		error('Expecting "output" and "input" to have the same dimensions');
	end
	
	U = null(output.')*null(input.')' + output*input';
	
end
