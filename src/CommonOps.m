classdef CommonOps
    % A static class to define common operators (Hadamard, CNOT, etc)
    
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


   
	%----------------------------------------------------------------------
	%  Methods that return matrices acting on Hilbert space
	%----------------------------------------------------------------------
	methods (Static)
		function U = swap(n, q1, q2)
			% With no input arguments, outputs the standard 2-qubit swap
			% gate. Otherwise, creates a unitary on n qubits which swaps
			% qubits q1 and q2
			if nargin == 0
				U = [1 0 0 0; 0 0 1 0; 0 1 0 0; 0 0 0 1];
			elseif nargin == 3
				if ~issizelike([n q1 q2]) || q1>n || q2>n
					error('Expecting positive integers with q2,q1<=n');
				end
				N = 1:n;
				N(q1)=q2;
				N(q2)=q1;
				f = @(x) persub(x, N, 2*ones(1,n));
				U = matrixform(f, [1 2^n], [1 2^n]);
			else
				error('Unexpected number of inputs');
			end
		end
		function H = hadamard(n, q)
			% With no input arguments, outputs the standard 1-qubit
			% hadamard unitary. Otherwise, outputs a unitary on n qubits,
			% where the qubits listed in the array q have Hadamards, and
			% the rest have identities
			if nargin ==0
				H = [1 1; 1 -1]/sqrt(2);
			elseif nargin == 2
				if ~issizelike(n) || ~issizelike(q) || length(n) > 1 || max(q) > n
					error('Expecting positive integers with max(q)<=n');
				end
				H = zeros(1,n);
				H(q) = 1;
				H = arrayfun(@populate, H, 'UniformOutput', false);
				H = tensor(H{:});
			else
				error('Unexpected number of inputs');
			end
			function X = populate(b)
				if b == 0
					X = eye(2);
				else
					X = CommonOps.hadamard;
				end
			end
		end
		function U = cnot(n, control, target)
			% With no inputs, this returns the standard CNOT matrix.
			% Otherwise, this returns the control not unitary on n qubits
			% with the target and control registers specified
			if nargin == 0
				U = [1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 1 0];
			else
				if ~issizelike(n) || ~issizelike(target) || ~issizelike(control) || length(n) > 1 || length(target) > 1 || length(control) > 1 || max(target,control) > n
					error('Expecting positive integers with max(control,target)<=n');
				end
				if control == target
					error('The control must be different from the target');
				end
				U = extendgate(CommonOps.cnot, 2*ones(1,n), [control target]);
			end
		end
		function ad = creation(n)
			% Outputs the nxn truncated creation operator
			ad = diag(sqrt(1:n-1),-1);
		end
		function ad = annihilation(n)
			% Outputs the nxn truncated creation operator
			ad = diag(sqrt(1:n-1),1);
		end
	end

    %----------------------------------------------------------------------
	%  Methods that return SuperOps
	%----------------------------------------------------------------------
	methods (Static)
		function op = swapSO(n, q1, q2)
			% With no input arguments, outputs the standard 2-qubit swap
			% gate. Otherwise, creates a SuperOp on n qubits which swaps
			% qubits q1 and q2
			if nargin == 0
				U = CommonOps.swap;
			elseif nargin == 3
				U = CommonOps.swap(n, q1, q2);
			else
				error('Unexpected number of inputs');
			end
			op = SuperOp(U,'conjugation');
		end
		function op = hadamardSO(n,q)
			% With no input arguments, outputs the standard 1-qubit
			% hadamard SuperOp. Otherwise, outputs a SuperOp on n qubits,
			% where the qubits listed in the array q have Hadamards, and
			% the rest have identities
			if nargin == 0
				U = CommonOps.hadamard;
			elseif nargin == 2
				U = CommonOps.hadamard(n, q);
			else
				error('Unexpected number of inputs');
			end
			op = SuperOp(U,'conjugation');
		end
		function op = cnotSO(n, control, target)
			% With no inputs, this returns the standard CNOT SuperOp.
			% Otherwise, this returns the CNOT SuperOp on n qubits
			% with the target and control registers specified
			if nargin == 0
				U = CommonOps.cnot;
			else
				U = CommonOps.cnot(n, control, target);
			end
			op = SuperOp(U,'conjugation');
		end
		function op = ptransposeSO(whichsys, dims)
			% Outputs the partial transpose superoperator. "dims" is a list
			% of dimensions of the subsystems, and "whichsys" is a list of
			% indeces indicating which subsystems you wish to transpose.
			% The inputs are the same as the function ptranspose.
			op = SuperOp({@(x) ptranspose(x, whichsys, dims) prod(dims) prod(dims)}, 'handleform');
		end
		function op = collectiveQubitNoise(n, p0, px, py, pz)
			% Create a collective noise channel on n qubits, with
			% probabilities for each of the four gates given by p0, px, py,
			% and pz
			if ~issizelike(n) || length(n) > 1
				Error('"n" is expected to be a non-negative integer');
			end
			if ~isnumeric(p0) || ~isnumeric(px) || ~isnumeric(py) || ~isnumeric(pz) || numel(p0) > 1 || numel(px) > 1 || numel(py) > 1 || numel(pz) > 1
				Error('"p0", "px", "py", "pz" are expected to be probabilities');
			end
			I = sqrt(p0)*eye(2^n);
			JX = sqrt(px)*Pauli.JX(n);
			JY = sqrt(py)*Pauli.JY(n);
			JZ = sqrt(pz)*Pauli.JZ(n);
			op = SuperOp(cat(3,I,JX,JY,JZ),'krausops');
		end
	end
end
