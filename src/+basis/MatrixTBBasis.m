classdef MatrixTBBasis < basis.ONBasis
	% A ON basis for rows by cols matrices, using the Top-to-Bottom
	% ordering convention
	
	properties
		cols		% The number of columns of each basis element
		rows		% The number of rows of each basis element
	end
	
	methods
		function self = MatrixTBBasis(r, c)
			% the constructor; the inputs c and r are respectively the
			% number of columns and rows in each basis element
			self.cols = c;
			self.rows = r;
			
			self.name = sprintf('%dx%d matrix basis with TB ordering convention', r, c);
			% set the basis
			self.basis = reshape(eye(c*r), r, c, c*r);
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
	
	methods (Access=protected)
		function c = computeStructureCoeffs(self)
			%c = computeStructureCoeffs@basis.Basis(self);

			% there must be a way to do this with out these loops...
			c = zeros(self.dimension*[1 1 1]);
			for k = 1:self.dimension
				for l = 1:self.dimension
					i = mod(k-1,self.rows)+1;
					j = ceil(k/self.rows);
					m = mod(l-1,self.rows)+1;
					n = ceil(l/self.rows);
					if j == m
						c(k,l,(n-1)*self.rows+i) = 1;
					end
					if i == n
						c(k,l,(j-1)*self.rows+m) = c(k,l,(j-1)*self.rows+m) -1;
					end
				end
			end

		end
	end
end