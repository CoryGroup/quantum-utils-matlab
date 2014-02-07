classdef MatrixLRBasis < basis.ONBasis
	% A ON basis for rows by cols matrices, using the Left-to-Right
	% ordering convention
	
	properties
		cols		% The number of columns of each basis element
		rows		% The number of rows of each basis element
	end
	
	methods
		function self = MatrixLRBasis(r, c)
			% the constructor; the inputs c and r are respectively the
			% number of columns and rows in each basis element
			self.cols = c;
			self.rows = r;
			
			self.name = sprintf('%dx%d matrix basis with LR ordering convention', r, c);
			% set the basis
			self.basis = permute(reshape(eye(c*r), r, c, c*r), [2 1 3]);
			% don't bother with labels, at least not yet
		end		
		
		function set.cols(self, d)
			% This set method actually constructs the basis
			% as well as setting cols
			if round(d) ~= d || d < 1
				error('Expecting a positive integer number for cols');
			end
			
			self.cols = d;
		end
		function set.rows(self, d)
			% This set method actually constructs the basis
			% as well as setting cols
			if round(d) ~= d || d < 1
				error('Expecting a positive integer number for rows');
			end
			
			self.rows = d;
		end
	end
end