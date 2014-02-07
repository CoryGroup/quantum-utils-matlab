function A = unvec(v, sbasis, dims)
    % Unvectorizes the vector v. If no sbasis is supplied, the column stacking
    % convention is assumed.
    %
    % WARNING: this function was previously called mat. Any code using the old
    % function name should be changed.
    %
    % Arguments:
    %	- v:		The column vector to unvectorize into an array.
    %	- sbasis:	The unstacking basis, an instance of the Basis class OR the 
    %				strings 'col' or 'vec' to use column or row unstacking 
    %				conventions respectively. This input is optional, and when
    %				not present, the column unstacking convention will be used.
    %	- dims:		Only relevant if the row or column unstacking conventions
    %				used. In these cases, dims should be a vector containing
    %				the dimensions of the output array, of course satisfying
    %				prod(dims) = length(v). If the row or column unstacking
    %				conventions are set but dims is not, it will attempt to
    %				unvectorize into a square 2D array.
    %
    % Outputs:
    %	- A:		The unvectorized version of v
    %
    % See Also:
    %	- The Basis class and its children, in the +basis folder
    %	- The inverse of this function, vec
    %
    % Warning:
    %	It was unclear to me what the natural row stacking convention is for
    %	arrays with more than 3 indeces. The one at present does not seem quite
    %	natural, but it also seems that it is not worth my time to fix.
    %
    % Usage Example:
    %	A = magic(8);					% Create an 8x8 matrix
    %	B = basis.PauliONBasis(3);		% Create a 3qubit Pauli basis
    % 
    %	% Now we can verify that mat unvectorizes correctly:
    %	hsnorm(A - unvec(vec(A)))
    %	hsnorm(A - unvec(vec(A,'col'), 'col'))
    %	hsnorm(A - unvec(vec(A, B), B))
    %
    %	A = rand(4, 6, 2);		Some crazy array
    %	% Now we can verify that mat unvectorizes correctly:
    %	hsnorm(A - unvec(vec(A), 'col', [4, 6, 2]))		 % with column convention
    %   hsnorm(A - unvec(vec(A, 'row'), 'row', [4, 6, 2])) % with row convention
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

	if ~isnumeric(v) || length(v)+1 ~= sum(size(v))
		error('v should be a numeric 1D vector');
	end

	% default value for basis
	if nargin == 1
		sbasis = 'col';
	end
	
	if ischar(sbasis) 
		% the basis was given as a string
		
		if nargin < 3
			% dims wasn't given, check if v can be made into a square
			% matrix
			d = sqrt(length(v));
			if round(d) == d
				dims = [d d];
			else
				error('Your vector cannot be made into a square matrix, please specify dims');
			end
		else
			% dims was given, check if it is consistent
			if prod(dims) ~= length(v)
				error('Your requested dimensions are not consistent with the size of your vector');
			end
		end
		
		if strcmp(sbasis, 'col')
			% column unstacking convention
			A = reshape(v, dims);
		elseif strcmp(sbasis, 'row')
			% row unstacking convention
			perm = [2 1 3:length(dims)];
			A = permute(reshape(v, dims(perm)), perm);
		else
			error('sbasis string incorrect. Please see documentation');
		end
		
	elseif ~isempty(findstr(class(sbasis), 'basis.'))
		% unstack with respect to an instance of a Basis class
		
		A = sbasis.createFromCoeffs(v);
	else
		error('Invalid basis input, see documentation');
	end

end
