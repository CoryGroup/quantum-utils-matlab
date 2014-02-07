classdef ColumnBasis < basis.ONBasis
	% A ON basis for column vectors
	
	properties
		rows		% The number of rows in the column. Note that rows will be equal to dimension.
	end
	
	methods
		function self = ColumnBasis(r)
			% the constructor; the input r is the number of rows in the
			% column. The basis is constructed in the set method for rows
			self.rows = r;
		end		
		
		function set.rows(self, d)
			% This set method actually constructs the column vector basis
			% as well as rows
			if round(d) ~= d || d < 1
				error('Expecting a positive integer number for rows');
			end
			
			% The basis is just
			B = reshape(eye(d), d, 1, d);
			% preallocate space for the labels
			L = cell(1, d);
			
			for k = 1:d
				L{k} = sprintf('R%d', k);
			end
			
			% Populate the self
			self.name = sprintf('Column basis of %d rows', d);
			self.basis = B;
			self.labels = L;
			self.rows = d;
		end
	end
end