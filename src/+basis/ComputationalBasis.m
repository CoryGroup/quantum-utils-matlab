classdef ComputationalBasis < basis.ONBasis
	% The canonical column basis used in QIP for an integer number of
	% qubits

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
