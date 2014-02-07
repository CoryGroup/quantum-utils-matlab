classdef PauliONBasis < basis.ONBasis
	% A nqubit orthonormal Pauli Basis (WARNING: the elements of this basis
	% are normalized to the hs norm, so that, for example the basis will
	% contain the element tensor(X,X,X)/sqrt(2^3) rather than tensor(X,X,X)
	% itself)
	
	properties
		nqubits		% The number of qubits the basis elements act on
	end
	
	methods
		function self = PauliONBasis(nqubits)
			% the constructor; input the number of qubits, and the Pauli
			% ON basis will be constructed (see the set method of nqubits to
			% see how the basis is constructed).
			self.nqubits = nqubits;
		end		
		
		function set.nqubits(self, n)
			% This set method actually constructs the ON Pauli basis; if you
			% change the number of qubits, it will calculate the new Pauli
			% basis
			if round(n) ~= n || n < 1
				error('Expecting a positive integer number of qubits');
			end
			
			% The following generates an n-qubit Pauli basis. If you have a
			% more efficient way of implementing it, please share.
			
			% preallocate space for the labels
			L = cell(1, 4^n);
			% preallocate space for the basis
			B = zeros(2^n, 2^n, 4^n);
			
			% k will index which pauli product operator we are on
			for k = 1:4^n
				% convert k-1 into a string, showing k-1 in base 4
				base4 = dec2base(k-1, 4, n);
				tmp = 1;
				for l = 1:n
					% pull out the l'th base 4 digit, and kronecker it on
					tmp = kron(tmp, Pauli.p(str2double(base4(l))));
				end
				B(:,:,k) = tmp;
				
				% to get the label, just do a string replacement
				L{k} = regexprep(base4, {'0','1','2','3'}, {'I','X','Y','Z'});
			end
			
			% right now we are only orthogonal wrt hs, so normalize
			B = B/2^(n/2);
			
			% Populate the self
			self.name = sprintf('%d-qubit ON Pauli Basis', n);
			self.basis = B;
			self.labels = L;
			self.nqubits = n;
		end
	end
	
end