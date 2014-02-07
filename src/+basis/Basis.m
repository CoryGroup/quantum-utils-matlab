classdef Basis < handle
	% A class devoted to linearly independent spanning sets of arrays

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
		basis				% A numerical array whose last dimension indexes the basis
		labels				% Labels for your basis elements. A cell of strings whose length should be the same as the basis dimension
		field = 'complex'	% Either the real or the complex numbers, default is complex
		thresh = 1e-10		% The threshhold for considering coefficients to be 0 when expanding in terms of the basis
		name				% A place to store a human readable name for the basis
	end
	
	properties (Dependent)
        dimension		% The number of basis elements (note that there exist situations that this may not be equal to the dimension of the space)
		size			% The size of each basis element
		issquare		% True if the basis elements are square matrices, false otherwise
		standardform	% A 2D array, where each column is a columnized basis element, and the number of columns is the dimension
		inverse			% The inverse matrix of standardform
        structurecoeffs	% The 3D array of each commutation expanded in terms of the basis (only possible if the basis spans a lie algebra). [B(i),B(j)] = sum(C(i,j,k)B(k),k)
    end
    
    properties (Access=private)
        % cached variables, so they don't have to be recomputed everytime
        c_standardform 
        c_inverse
        c_structurecoeffs
    end
	
	methods
		function self = Basis(B, L, F)
			% the constructor; B is the basis, L are the labels, and F is the field
			if nargin > 0
				self.basis = B;
			end
			if nargin > 1
				self.labels = L;
			end
			if nargin > 2
				self.field = F;
			end
		end
		
		% begin get and set methods
		function dim = get.dimension(self)
			if isempty(self.basis)
				error('No basis has been input yet');
			end
			sizes = size(self.basis);
			% if basis is a 2D array, the basis only has one element
			if length(sizes) == 2
				dim = 1;
			else
				dim = sizes(end);
			end
		end
		function s = get.size(self)
			if isempty(self.basis)
				error('No basis has been input yet');
			end
			sizes = size(self.basis);
			% if basis is a 2D array, it is equal to the only basis element
			if length(sizes) == 2
				s = sizes;
			else
				s = sizes(1:end-1);
			end
		end
		function s = get.standardform(self)
			if isempty(self.basis)
				error('No basis has been input yet');
            end
            if isempty(self.c_standardform)
                self.c_standardform = reshape(self.basis, prod(self.size), self.dimension);
            end
            s = self.c_standardform;
		end
		function s = get.inverse(self)
			if isempty(self.basis)
				error('No basis has been input yet');
            end
            if isempty(self.c_inverse)
                if isa(self, 'basis.ONBasis') && self.iphs
					% the inverse takes a simple form in the ON case
					self.c_inverse = self.standardform';
				else
					 self.c_inverse = inv(self.standardform);
                end
            end
            s = self.c_inverse;
		end
		function s = get.issquare(self)
			if isempty(self.basis)
				error('No basis has been input yet');
			end
			bsize = self.size;
			s = true;
			if length(bsize) ~= 2
				% return false if basis element other than 2 dimensions
				s = false;
			end
			if bsize(1) ~= bsize(2)
				% return false if the 2 dimensions are not the same
				s = false;
			end
		end
		function s = get.structurecoeffs(self)
			if isempty(self.basis)
				error('No basis has been input yet');
			end
			if ~self.issquare
				error(['The basis must consist of square matrices ' ...
					   'for the structure coefficients to make sense']);
            end
            if isempty(self.c_structurecoeffs)
                self.c_structurecoeffs = self.computeStructureCoeffs();
            end
            s = self.c_structurecoeffs;
		end
		function set.labels(self, L)
			n = length(L);
			if min(size(L)) > 1 && n > 1
				error('The labels should be a 1D cell of strings');
			end
			for k = 1:n
				if ~ischar(L{k})
					error('Entry %d of your labels cell is not a string', k);
				end
			end
			if ~isempty(self.basis) && self.dimension > n
				warning('There are more basis elements than labels');
			end
			self.labels = L;
		end
		function set.field(self, F)
			if strcmp(F, 'real')
				self.field = 'real';
			elseif strcmp(F, 'complex')
				self.field = 'complex';
			else
				error('The field must be real or complex');
			end
		end
		function set.basis(self, B)
			if ~isa(B, 'numeric')
				error('The basis should be an array of numerical values.');
			end
			% Reshape each basis element into a column of the matrix and
			% check that it has full rank.
			s = size(B);
			R = reshape(B, prod(s(1:end-1)), s(end));
			if rank(R) < s(end)
				warning('The basis is not linearly independent');
			end
			self.basis = B;
            self.resetCache();
		end
		% end get and set methods
		
		function coeffs = expandToCoeffs(self, vec)
			% Every vector living in the same space as the basis can be
			% expressed as a linear combination of the basis elements. This
			% method returns these coefficients (in the same order as the
			% basis).
			
			if size(vec) ~= self.size
				error('The vectors size must match the basis element sizes');
			end
			
			% Just columnize everything including the basis, and the
			% inverse basis will tell us the coefficients upon
			% multiplication with vec.
			coeffs = self.inverse*reshape(vec, numel(vec), 1);
		end
		function str = expandToStr(self, vec, form)
			% Every vector living in the same space as the basis can be
			% expressed as a linear combination of the basis elements. This
			% method returns a string detailing the linear combination of
			% the array vec in terms of the basis labels. "form" is an
			% optional input whose default input is 'single'. It's posible
			% values are:
			%		'single':	display all information on one line
			%		'table':	put each basis element on its own line
			%		'cell':		outputs str as a cell such that str{k}{1}
			%					is the k'th non-zero basis label, and
			%					str{k}{2} is the k'th non-zero coefficient
			
			if isempty(self.labels)
				error('The labels have not been set.');
			end
			if nargin < 3
				form = 'single';
			end
			
			% the coefficients
			coeffs = self.expandToCoeffs(vec);
			
			% the indeces of the non-zero coefficients
			indeces = 1:self.dimension;
			indeces = indeces(abs(coeffs)>self.thresh);
			
			if strcmp(form, 'single')
				% the format of each line to print
				printformat = '(%s)*%s + ';
				
				% now loop through and print
				str = arrayfun(@(k) sprintf(printformat, ...
											writenumber(coeffs(k),1,4,false), ...
											self.labels{k}), ...
											indeces, 'UniformOutput', 0);
				str = [str{:}];	
				
				% remove the leading plus sign
				if ~isempty(str), str = str(1:end-3);	end
				
			elseif strcmp(form, 'table')
				% get the maximum label length
				maxlength = max(cellfun(@length, self.labels));

				% the format of each line to print
				printformat = ['%' num2str(maxlength) 's' '\t  %s\n'];
				
				% now loop through and print
				str = arrayfun(@(k) sprintf(printformat, self.labels{k}, ...
											writenumber(coeffs(k),1,5,true)), ...
											indeces, 'UniformOutput', 0);
				str = [str{:}];		
			elseif strcmp(form, 'cell')
				% get the maximum label length
				maxlength = max(cellfun(@length, self.labels));

				% the format of each line to print
				printformat = ['%' num2str(maxlength) 's'];
				
				% now loop through and print
				str = arrayfun(@(k) {sprintf(printformat, self.labels{k}), ...
									 writenumber(coeffs(k),1,5,true)}, ...
								     indeces, 'UniformOutput', 0);
			else
				error('Unexpected "form" input.');
			end
			function str = writenumber(num, dig, frac, space)
				% turn the complex number num into a string. dig is the
				% number of digits to display before the decimal point,
				% frac, the number to display after the decimal point, and
				% space is true if you want the middle operation (+ or -)
				% to have spaces around it
				re = real(num);
				im = imag(num);
				ss = ['%' num2str(dig) '.' num2str(frac) 'f'];
				if sign(re) == 1, repre = ' ';
				else 			  repre = '-';		end
				if sign(im) == 1, impre = '+';
				else 			  impre = '-';	end
				if space
					impre = [' ' impre ' '];
				end
				str = sprintf([repre ss impre ss 'i'], abs(re), abs(im));
			end
		end
		function vec = createFromCoeffs(self, coeffs)
			% given a vector of coefficients whose length is equal to the
			% number of basis elements, the corresponding linear sum is
			% output
			
			if ~isnumeric(coeffs)
				error('Your coefficients should be numbers');
			end
			if sum(size(coeffs)) ~= max(size(coeffs)) + 1
				error('Coeffs must be a 1D array of numbers');
			end
			if length(coeffs) ~= self.dimension
				error('There should be as many coefficiets as basis elements');
			end
			
			% if we were given a row instead of a column, transpose it
			if size(coeffs, 1) == 1
				coeffs = coeffs.';
			end
			
			% now multiply and reshape
			vec = reshape(self.standardform*coeffs, self.size);
		end
		function b = be(self, n)
			% returns the n'th basis element
			
			l = length(self.size);
			
			% a switch the for the most likely cases for speed
			if l == 2
				b = self.basis(:,:,n);
			elseif l == 1
				b = self.basis(:,n);
			else
				% get the n'th column from standard form and reshape it
				% correctly
				b = reshape(self.standardform(:,n), self.size);
			end
		end
		function self = permuteOrder(self, permutation)
			% Permutes the order of a basis and its labels. The input
			% permutation is a 1D vector of equal length to the basis
			% dimension containing each integer from 1 to the dimension

			if length(permutation) ~= self.dimension
				error('The permutation must have the same length as the basis dimension');
			end
			if hsnorm(sort(permutation) - 1:self.dimension) ~= 0
				error('The permutation must contain all of the integers from 1 to the basis dimension');
			end
			
			% reshape the reorderd columns of standardform
			self.basis = reshape(self.standardform(:,permutation), size(self.basis));
			
			% if someone knows a better way of permuting the elements of a
			% cell array than the following, please share.
			L = cell(1, self.dimension);
			for k = 1:self.dimension
				L{k} = self.labels{permutation(k)};
			end
			self.labels = L;
		end
		function b = inSpan(self, vec)
			% Returns true iff vec lies in the span of the basis
			if strcmp(self.field, 'complex')
				b = rank([self.standardform vec(:)]) <= self.dimension;
			elseif strcmp(self.field, 'real')
				b = rank([[real(self.standardform);imag(self.standardform)] [real(vec(:));imag(vec(:))]]) <= self.dimension;
			end
		end
		function b = subspaceOf(self, super)
			% Returns true iff self spans a space which is a subspace of
			% super
			if sum(abs(self.size-super.size)) ~=0
				error('Spaces must have elements with equal dimensions');
			end
			% concatinate standard forms and check to see if self adds any
			% rank
			
			if strcmp(self.field, 'complex')
				b = rank([self.standardform super.standardform]) == super.dimension;
			elseif strcmp(self.field, 'real')
				b = rank([[real(self.standardform);imag(self.standardform)] [real(super.standardform);imag(super.standardform)]]) == super.dimension;
			end
		end
		function b = eq(b1, b2)
			% checks to see if they span the same space
			if strcmp(b1.field, 'complex')
				R = rank([b1.standardform b2.standardform]);
				b = R == b1.dimension && R == b2.dimension;
			elseif strcmp(b1.field, 'real')
				R = rank([[real(b1.standardform);imag(b1.standardform)] [real(b2.standardform);imag(b2.standardform)]]);
				b = R == b1.dimension && R == b2.dimension;
			end
		end
    end
    
    methods (Access=private)
        function resetCache(self)
            % reset all of the cached variables
            self.c_standardform = [];
            self.c_inverse = [];
            self.c_structurecoeffs = [];
		end
	end
	methods (Access=protected)
		function c = computeStructureCoeffs(self)
			% we put this as a private function so that it can be
			% overridden by subclasses where the structure coeffs are more
			% tractably computed
			c = zeros(self.dimension*[1 1 1]);
			% just do a loop
			for i = 1:self.dimension
				for j = 1:self.dimension
					c(i,j,:) = self.expandToCoeffs(comm(self.be(i),self.be(j)));
				end
			end
		end
    end
			
	
end
