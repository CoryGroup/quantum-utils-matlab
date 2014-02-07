classdef RandomBasis < basis.Basis
	% A basis for the space of (multidimensional) arrays, whose elements
	% are generated randomly from the complex numbers in the unit square
	

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