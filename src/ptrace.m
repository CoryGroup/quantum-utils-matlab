function x = ptrace(p, traceout, dims)
    % Takes the partial trace of a matrix p
    %
    % Arguments:
    %	p:			The matrix or vector to do a partial trace on
    %	traceout:	The subsystem(s) to trace out
    %	dims:		The dimensions of the tensor spaces
    %
    % Outputs:
    %   x:          The partial trace of p with respect to the parameters
    %               traceout and dims
    %
    % Usage Example:
    %		Suppose you have a qubit/qutrit/qubit system, so that p is a
    %		12x12 density matrix. Then:
    %
    %			ptrace(p, n, [2 3 2]) traces out the n'th system
    %			ptrace(p, [1 3], [2 3 2]) traces out both qubits

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


	% check arguments
	if any(traceout > length(dims)) || any(traceout < 0)
		error('Invalid subsystem in traceout')
	end
	if (length(dims) == 1 && mod(length(p)/dims,1) ~= 0) || length(p) ~= prod(dims)
		error('Size of state p inconsistent with dims');
	end


	% remove singleton dimensions
	traceout = setdiff(traceout,find(dims == 1));
	dims = dims(dims ~= 1);


	% calculate systems, dimensions, etc.
	n = length(dims);
	rdim = dims(end:-1:1);
	keep = 1:n;
	keep(traceout) = [];
	dimtrace = prod(dims(traceout));
	dimkeep = length(p)/dimtrace;


	if any(size(p) == 1)
		% state vector
		if size(p,1) == 1

		end

		% reshape state vector to "reverse" ket on traced subsystems into a bra,
		% then take outer product
		perm = n+1-[keep(end:-1:1),traceout];
		x = reshape(permute(reshape(p,rdim),perm),[dimkeep,dimtrace]);
		x = x*x';

	else
		% density matrix

		% reshape density matrix into tensor with one row and one column index
		% for each subsystem, permute traced subsystem indices to the end,
		% reshape again so that first two indices are row and column
		% multi-indices for kept subsystems and third index is a flattened index
		% for traced subsystems, then sum third index over "diagonal" entries
		perm = n+1-[keep(end:-1:1),keep(end:-1:1)-n,traceout,traceout-n];
		x = reshape(permute(reshape(p,[rdim,rdim]),perm), [dimkeep,dimkeep,dimtrace^2]);
		x = sum(x(:,:,[1:dimtrace+1:dimtrace^2]),3);

	end
end


