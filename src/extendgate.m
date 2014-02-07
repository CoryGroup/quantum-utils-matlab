function X = extendgate(gate, dimsout, pos)
    % Extends an operator on a "small" multi-partite system to an operator a
    % "large" multi-partite system by adding an identity channel to each of the
    % new systems introduced.
    %
    % Arguments:
    %	- gate:		A square matrix, probably unitary OR a SuperOp instance
    %	- dimsout:	The tensorial structure of the larger Hilbert space; a
    %				1D array of dimensions whose product is the dimension of
    %				the larger Hilbert space.
    %	- pos:		A 1D array of positive integers	whose maximum value is no
    %				bigger than length(partout).
    %				pos(k) is the position of the bigger Hilbert space to put
    %				the k'th part of U into.
    %
    % Outputs:
    %	- X:		Square matrix X acting on the bigger Hilbert space 
    %	
    %
    % Usage Example:
    %
    % % This is just a demonstration; CommonOps.cnot() already can do this
    % % first example. But we make a CNOT unitary between the last and the
    % % first qubit  on a 4 qubit system:
    % U = extendgate(CommonOps.cnot, [2 2 2 2], [4 1]);
    % % and we can control on the opposite qubit with
    % U = extendgate(CommonOps.cnot, [2 2 2 2], [1 4]);
    %
    % % Next, consider a CNOT with noise. We do the same thing as the above
    % kraus = cat(3, sqrt(0.9)*CommonOps.cnot, sqrt(0.1)*Pauli.parseString('XX'));
    % cnot = SuperOp(kraus, 'krausops');
    % bigcnot = extendgate(cnot, [2 2 2 2], [4 1]);
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



	if ~issizelike(dimsout) || ~issizelike(pos)
		error('"dimsout" and "pos" are expected to be 1D arrays of positive integers.');
	end
	if max(pos) > length(dimsout)
		error('the maximum value of "pos" should be no larger than length(dimsout).');
	end
	
	% just make sure they are row vectors
	dimsout = dimsout(:).';
	pos = pos(:).';
	
	finaldim = prod(dimsout);
	
	if isnumeric(gate)
		%if it's a matrix, use extendmatrix (below)
		if size(gate,1) ~= size(gate,2)
			error('the matrix "gate" expected to be a square.');
		end	
		if prod(dimsout(pos)) ~= length(gate)
			error('The product of the input dimensions (i.e. dimsout(pos)) should be length(U).');
		end
		X = extendmatrix(gate);
	elseif isa(gate, 'SuperOp')
		% if it's a SuperOp, use extendmatrix on each of the kraus
		% operators
		if gate.inputdim ~= gate.outputdim
			error('The case for unequal input and output dimensions is not yet implemented');
		end
		if prod(dimsout(pos)) ~= gate.outputdim
			error('The product of the input dimensions (i.e. dimsout(pos)) do not match the "gate".');
		end
		krausleft = zeros(finaldim,finaldim,gate.krausnum);
		krausright = zeros(finaldim,finaldim,gate.krausnum);
		for k = 1:gate.krausnum
			krausleft(:,:,k) = extendmatrix(gate.krausops{1}(:,:,k));
			krausright(:,:,k) = extendmatrix(gate.krausops{2}(:,:,k));
		end
		X = SuperOp({krausleft krausright},'krausops');
	else
		error('"gate" is of an unexpected type');
	end

	
	function Y = extendmatrix(A)
		% this function extends an operator on Hilbert space
		
		% first pretend that the extra tensors are all to the right of the
		% original space
		Y = tensor(A,eye(2^(length(dimsout)-length(pos))));

		% how to permute the tensorial structure to get the factors in question
		% to the front
		perm = 1:length(dimsout);
		perm(pos) = [];
		perm = [pos perm];

		% permute the original system to the front, apply X, and then permute
		% back to usual
		action = @(v) persub(Y*persub(v,perm,dimsout),perm,dimsout);

		% now turn this into a matrix
		Y = matrixform(action, [finaldim,1], [finaldim,1]);
	end

end
