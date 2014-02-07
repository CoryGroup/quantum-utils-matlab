classdef ComputationalBasis < basis.ONBasis
	% The canonical column basis used in QIP for an integer number of
	% qubits
	
	properties
		numqubits		% The number of qubits in the system
	end
	
	methods
		function self = ComputationalBasis(numqubits)
			% the constructor; input the number of qubits desired. 
			% The basis is constructed in the set method for numqubits
			self.numqubits = numqubits;
		end		
		
		function set.numqubits(self, n)
			% This set method actually constructs the column vector basis
			% as well as rows
			if ~issizelike(n) || numel(n) > 1
				error('Expecting a positive integer number for "numqubits".');
			end
			
			N = 2^n;
			
			% The basis
			B = reshape(eye(N), [N 1 N]);
			
			% write the labels
			L = arrayfun(@(k) ['|' dec2bin(k,n) '>'], 0:N-1, 'UniformOutput', 0);
			
			% Populate the self
			self.name = sprintf('Computational basis on %d qubits', n);
			self.basis = B;
			self.labels = L;
			self.numqubits = n;
		end
	end
end