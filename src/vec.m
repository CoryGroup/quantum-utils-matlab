function v = vec(A, sbasis)
    % Vectorizes the array A into a column. If no sbasis is supplied, the 
    % column stacking convention is assumed.
    %
    % Arguments:
    %	- A:		The numerical array to vectorize. A need not have only two
    %				dimensions
    %	- sbasis:	The stacking basis, an instance of the Basis class OR the 
    %				strings 'col' or 'row' to use column or row stacking 
    %				convention respectively. This input is optional, and when
    %				not present, the column stacking convention will be used.
    %
    % Outputs:
    %	- v:		The vectorized A, a numel(A)-by-1 matrix.
    %
    % See Also:
    %	- The Basis class and its children, in the +basis folder
    %	- The inverse of this function, unvec
    %
    % Warning:
    %	It was unclear to me what the natural row stacking convention is for
    %	arrays with more than 3 indeces. The one at present does not seem quite
    %	natural, but it also seems that it is not worth my time to fix.
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

	if ~isnumeric(A)
		error('A should be a numeric array');
	end

	% default value for basis
	if nargin == 1
		sbasis = 'col';
	end
	
	if ischar(sbasis) && strcmp(sbasis, 'col')
		% column stacking convention
		v = reshape(A, numel(A), 1);
	elseif ischar(sbasis) && strcmp(sbasis, 'row')
		% row stacking convention
		v = reshape(permute(A, [2 1 3:length(size(A))]), numel(A), 1);
	elseif ~isempty(findstr(class(sbasis), 'basis.'))
		% stack with respect to an instance of a Basis class
		v = sbasis.expandToCoeffs(A);
	else
		error('Invalid basis input, see documentation');
	end

end
