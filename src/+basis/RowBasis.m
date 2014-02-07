classdef RowBasis < basis.ONBasis
	% A ON basis for row vectors
	
	properties
		cols		% The number of columns in the row. Note that cols will be equal to dimension.
	end
	
	methods
		function self = RowBasis(c)
			% the constructor; the input c is the number of columns in the
			% row. The basis is constructed in the set method for rows
			self.cols = c;
		end		
		
		function set.cols(self, d)
			% This set method actually constructs the row vector basis
			% as well as setting cols
			if round(d) ~= d || d < 1
				error('Expecting a positive integer number for cols');
			end
			
			% The basis is just
			B = reshape(eye(d), 1, d, d);
			% preallocate space for the labels
			L = cell(1, d);
			
			for k = 1:d
				L{k} = sprintf('C%d', k);
			end
			
			% Populate the self
			self.name = sprintf('Row basis of %d columns', d);
			self.basis = B;
			self.labels = L;
			self.cols = d;
		end
	end
end