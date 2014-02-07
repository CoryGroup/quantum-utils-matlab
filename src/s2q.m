function q = s2q(str)
    % Converts a string of 0's and 1's into the corresponding qubit from the
    % computational basis
    %
    % Arguments:
    %	- str:	A string of 0's and 1's
    %
    % Outputs:
    %	- q:	the corresponding qubit from the computational basis
    %	
    %
    % Usage Example:
    %
    %	s2q('10101');
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


	% get number of qubits
	n = length(str);

	% set the appropriate entry to 1
	q = zeros(2^n, 1);
	q(bin2dec(str)+1) = 1;

end
