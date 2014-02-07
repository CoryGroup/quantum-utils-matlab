function x = hs(A,B)
    % Computes the Hilbert-Schmidt inner product of two matrices. In the case
    % that they are vectors, the usual inner product is computed.
    %
    % Arguments:
    %	- A,B:		Two square matrices (or 1D vectors) of the same dimension
    %
    % Outputs:
    %	- x:		Returns trace(A'*B) if matrices, or the equivalent if
    %				vectors
    %
    % Usage Example:
    %	hs(rand(10), rand(10))
    %	hs(rand(1,10), rand(10,1))	% whether they are columns or vectors or both does not matter, but the first is always conjugated
    %	hs(rand(10,1), rand(10,1))
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



	% check inputs for errors
	if ~isnumeric(A) || ~isnumeric(B)
		error('Numeric inputs expected');
	end
	nA = numel(A);
	nB = numel(B);
	if nA ~= nB
		error('Dimension mismatch between A and B');
	end

	% Force a reshape into a row and column, and then multiply. Don't forget
	% about the conjugation
	x = reshape(conj(A), 1, nA)*reshape(B, nB, 1);


end
