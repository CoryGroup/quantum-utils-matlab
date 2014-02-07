function mat = irand(varargin)
    % Outputs a random complex matrix. The same as the builtin function rand,
    % except outputs a random complex matrix.
    %
    % Arguments:
    %	- varargin:		This is just whatever you would put into the builtin
    %					function rand.
    %
    % Outputs:
    %	- mat:			The random output matrix
    %
    % See Also:
    %	- rand
    %
    %
    % Usage Example:
    %	A = magic(8);					% Create an 8x8 matrix
    %	B1 = basis.PauliONBasis(3);		% Create a 3qubit Pauli basis
    %	B2 = basis.MatrixTBBasis(8,8);	% Create a standard TB matrix basis
    %	B3 = basis.MatrixLRBasis(8,8);	% Create a standard LR matrix basis
    % 
    %	vA1 = vec(A, B1);		% vectorize A using the Pauli convention
    %	vA2 = vec(A, B2);		% vectorize A using B2
    %	vA3 = vec(A, B3);		% vectorize A using B3
    %	vA4 = vec(A);			% vectorize A using column stacking
    %	vA5 = vec(A, 'row');	% vectorize A using row stacking
    %	% Note that we will have vA2 = vA4 and vA3 = vA5
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


	% Just make random real and imaginary parts.
	mat = rand(varargin{:})+1i*rand(varargin{:});

end
