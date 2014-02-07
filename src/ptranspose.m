function x = ptranspose(p, whichsys, dims)
    % Takes the partial transpose of a matrix p
    %
    % Arguments:
    %	p:			The matrix to do a partial transpose on.
    %	whichsys:	The subsystem(s) to transpose. This input is a list of
    %				indexes referring to dims.
    %	dims:		The dimensions of the tensor spaces.
    %
    % Outputs:
    %   x:          The partial transpose of p with respect to the parameters
    %               whichsys and dims
    %
    % Usage Example:
    %
    % Suppose you have a qubit/qutrit/qubit system, so that p is a
    % 12x12 density matrix. Then:
    %
    %	ptranspose(p, n, [2 3 2]);		% transposes the n'th system
    %	ptranspose(p, [1 3], [2 3 2]);  % transposes both qubits

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


	if ~isnumeric(p) || length(size(p)) ~= 2 || size(p,1) ~= size(p,2)
		error('The input "p" is expected to be a square matrix');
	end
	if ~issizelike([whichsys dims]) || length(whichsys) > length(dims) || max(whichsys) > length(dims)
		error('"whichsys" and "dims" are expected to be 1D arrays of positive integers, where "whichsys" contains indeces pointing to "dims"');
	end
	if prod(dims) ~= length(p)
		error('The product of the dimensions (prod(dims)) is expected to be the width of "p"');
	end
	
	
	% these are just some index manipulations we will need
	n = length(dims);
	trans = zeros(1,n);
	trans(whichsys) = 1;
	trans = trans(end:-1:1);
	perm = [(1:n).*(~trans) + (n+1:2*n).*trans, (n+1:2*n).*(~trans) + (1:n).*trans];
	
	% we reshape to expand all of the indeces out, and then transpose the
	% selected systems, and then reshape back into 2D
	x = reshape(permute(reshape(p,  dims([end:-1:1,end:-1:1])),perm),[prod(dims) prod(dims)]);


end
