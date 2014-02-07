function C = centralizer(K, L)
    % K is a basis for a subspace of the space spanned by the basis L, where 
    % L spans some Lie algebra. This function computes a basis for the
    % centralizer of K in L
    %
    % Arguments:
    %	- K:    A basis for a subspace of the space spanned by L; an instance
    %           of the basis.Basis class
    %   - L:    A basis for a Lie algebra (it is up to the user to ensure
    %           this); an instance of the basis.Basis class
    %
    % Outputs:
    %	- C:	An ON basis for the centralizer of K in L, ie, a basis for the
    %			subspace of L of maximal dimension such that every member
    %			commutes with every member of K
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

	if ~isa(K, 'basis.Basis') || ~isa(L, 'basis.Basis')
		error('Expecting instances of basis.Basis as inputs');
	end
	if ~K.subspaceOf(L) || ~K.issquare
		error('K must be a subspace of the square matrix space L');
	end
	
	% If L is just spans the full matrix space, we will choose to use the
	% Top-Bottom standard matrix basis. This is simply because computing
	% the structure coefficients is faster in this case
	if L.dimension < prod(L.size) || isa(L, 'basis.MatrixTBBasis')
		B = L;
	else
		B = basis.MatrixTBBasis(L.size(1),L.size(2));
	end
	
	% first we write every basis element of K in terms of B
	D = zeros(K.dimension, B.dimension);
	for k = 1:K.dimension;
		D(k, :) = B.expandToCoeffs(K.be(k));
	end
	
	% now we compute a matrix whose null space will be the coefficent space
	% of the centralizer. See Lie Algebras: Theory and Algorithms (Graaf)
	% section 1.6 for where this matrix comes from (its pretty trivial)
	A = reshape(D*B.structurecoeffs(:,:), [K.dimension B.dimension B.dimension]);
	A = reshape(permute(A, [1 3 2]), [K.dimension*B.dimension B.dimension]);
	
	% now get the null space, and expand each one into our basis
	N = null(A);
	O = zeros([B.size size(N,2)]);
	for k = 1:size(N,2)
		O(:,:,k) = B.createFromCoeffs(N(:,k));
	end

	C = basis.Basis();
	C.basis = O;
	
	
end
