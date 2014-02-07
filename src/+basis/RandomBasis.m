classdef RandomBasis < basis.Basis
	% A basis for the space of (multidimensional) arrays, whose elements
	% are generated randomly from the complex numbers in the unit square

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
	

	methods
		function self = RandomBasis(dims)
			% the constructor; dims is a 1D array of positive integers
			% specifying the size of basis elements
            if ~issizelike(dims)
                error('Invalid input; expected vector non-negative integers.');
            end
			self.basis = self.generateBasis(dims);
		end		
    end
    
    methods (Access=private)
		function basis = generateBasis(self, dims)
			% this functions sets self.basis to a random basis
			if ~issizelike(dims)
				error('dims must be a 1D array of positive integers');
			end
			N = prod(dims);
			% make a random matrix with the right number of numbers
			mat = irand(N);
			% ensure our basis will be linearly independent with a while
			% loop
			while rank(mat) < N
				mat = irand(N);
			end
			% reshape to the correct size
			basis = reshape(mat, [dims N]);
		end
	end
end
