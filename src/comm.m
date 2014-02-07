function C = comm(A, B)
    % Takes the commutator of A and B
    %
    % Arguments:
    %	- A:	A square matrix
    %	- B:	A square matrix, of the same dimension as A
    %
    % Outputs:
    %	- C:	A*B-B*A
    %
    % Usage Example:
    %
    %	C = comm(Pauli.X, Pauli.Y);
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


	sA = size(A);
	sB = size(B);
	
	if length(sA) ~= 2 || length(sB) ~=2
		error('The input matrices must be 2D');
	end
	if sA(1) ~= sA(2) || sB(1) ~= sB(2)
		error('The input matrices must be square');
	end
	if sum(sA-sB) ~= 0
		error('The input matrices must have the same  dimension');
	end
	
	C = A*B-B*A;

end
