classdef CollectiveNoiseDFS < dfs.DFS
% Create a DFS for a collective n-qubit noise source. It would take too
% much documentation to explain everything that's going on here, so take a
% look at arXiv:math/0402105 for more info
	
	properties
		numphysqubits		% the number of physical qubits
		whichsys = 'max'	% which subsystem to choose (say n=numphysqubits, then whichsys must be an integer between 1 and (n-mod(n,2))/2+1) inclusive. If 'max', a maximal logical dimensional system will be chosen.
	end
	
	properties (Dependent)
		numlogqubits		% the number of logical qubits (rounds down the log2 of the logical dimension)
	end
	
	methods
		function self = CollectiveNoiseDFS(nphysqubits, whichsys)
			% the constructor; input the number of qubits, and a DFS will
			% be computed (done in the set method for nphysqubits). 
			if nargin > 1
				self.whichsys = whichsys;
			end
			self.numphysqubits = nphysqubits;
		end	
		
		% begin get and set methods
		function self  = set.whichsys(self, ws)
			% whichsys is either 'max' or a positive integer
			if strcmp(ws, 'max')
				self.whichsys = ws;
			elseif isnumeric(ws)
				if round(ws) ~= ws || ws < 0
					error('whichsys must be a positive integer');
				end
				self.whichsys = ws;
			else
				error('Unexpected whichsys input');
			end
		end
		function self = set.numphysqubits(self, n)
			% sets the number of physical qubits, AND, computes a
			% corresponding DFS for collective qubit noise
			if round(n) ~= n || n < 1
				error('Expecting a positive integer number of qubits');
			end
			if ~strcmp(self.whichsys,'max') && (self.whichsys > (n-mod(n,2))/2+1)
				error('You have selected a subsystem that is out of range. In this case, it should be between 1 and %d inclusive', (n-mod(n,2))/2+1);
			end
			
			% multiply the collective pauli generators; the dfs will lie in
			% one of the joint eigenspaces of JZ and JJ
			A = Pauli.JZ(n)*Pauli.JJ(n);
			
			% get the eigenvalues and eigenvectors. after this, we are
			% pretty much done. all that needs to happen is to choose which
			% eigenvectors to put in the first system of our dfs
			[U,D] = schur(A);
			D = round(diag(D));
			
			% this helper function will tell us which eigenvalue to take
			% the eigenvectors from
			[j, eigchoose] = calcEig(n, self.whichsys);
			
			% now discard the unwanted eigenvectors
			U = U(:, D==eigchoose);
			
			% U will be the basis of the first system, and we can act JP on
			% it to get the rest of the systems
			S = cell(1,2*j+1);
			p = size(U,1);
			q = size(U,2);
			S{1} = basis.ONBasis(reshape(U,[p 1 q]));
			JP = Pauli.JX(n) + 1i*Pauli.JY(n);
			for k = 2:round(2*j+1)
				scale = sqrt((JP*U(:,1))'*JP*U(:,1));
				U = JP*U;
				S{k} = basis.ONBasis(reshape(U/scale,[p 1 q]));
			end			
			
			% finally, populate the fields
			self.subsystems = S;
			self.numphysqubits = n;
		
			function [j d] = calcEig(n, ws)
				% a helper function
				% given n-qubits, calculate the eigenvalue of JJ*JZ
				% corresponding to ws (given by d) and which j produced it
				if strcmp(ws,'max')
					% we want the maximum possible dimension
					J = [mod(n,2)/2:1:n/2];
					getmax = zeros(length(J),1);
					for k = 1:length(J)
						% the following formula gives the dimension of the
						% associated logical space
						getmax(k) = nchoosek(n+1,round(J(k)+n/2+1))*(2*J(k)+1)/(n+1);
					end
					[~, ix] = max(getmax);
					% now calculate the corresponding eigenvalue
					[j, d] = calcEig(n, ix);
				else
					j = ws - 1 + mod(n,2)/2;
					d = -8*j*j*(j+1);
				end
			end
			
		end
		function n = get.numlogqubits(self)
			n = floor(log2(self.logicaldim));
		end
		% end get and set methods
	end
	
end