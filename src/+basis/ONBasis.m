classdef ONBasis < basis.Basis
	% A class devoted to orthonormal bases of arrays

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
		ip = @hs	% A handle to an inner-product function. Default to Hilbert-Schmidt inner product
	end
	
	properties (Dependent)
		iphs		% whether or not the inner-product is the hilbert schmidt inner product
	end
	
	methods
		function self = ONBasis(B, L, F, IP)
			% the constructor; B is the basis, L are the labels, and F is
			% the field, and IP is the inner product
			if nargin > 0
				self.basis = B;
			end
			if nargin > 1
				self.labels = L;
			end
			if nargin > 2
				self.field = F;
			end
			if nargin > 3
				self.ip = IP;
			end
		end		
		
		function set.ip(self, ipfcn)
			if ~isa(ipfcn, 'function_handle')
				error('ip must be a function handle of an inner product');
            end
			if nargin(func2str(ipfcn)) ~= 2
				error('Your inner product function should have two inputs');
			end
			self.ip = ipfcn;
		end
		function x = get.iphs(self)
			x = strcmp(func2str(self.ip), 'hs');
		end
		function coeffs = expandToCoeffs(self, vec, noip)
			% We overload this function in the case of orthonormality
			% because we have a (presumably) faster way of computing the
			% coefficients. If you would like to use the method found in
			% Basis.m instead, set noip=true
			
			% check if the flag noip is present
			if nargin < 3
				noip = false;
			end
					
			if noip
				% if noip, then use the naive inverse method found in
				% Basis.m 
				b = basis.Basis(self.basis);
				coeffs = b.expandToCoeffs(vec);
			else
				% otherwise use the inner product to find them
				if self.iphs
					% use an efficient method if we are using the
					% Hibert-Schmidt inner product
					coeffs = self.standardform'*reshape(vec, numel(vec), 1);
				else
					% otherwise loop through and calculate inner products
					coeffs = zeros(self.dimension,1);
					for k = 1:self.dimension
						coeffs(k) = self.ip(self.be(k), vec);
					end
				end
			end
		end
		function P = projector(self)
			% Outputs the orthogonal projector onto the space spanned by
			% this basis
			P = self.standardform*self.standardform';
		end
		function x = checkON(self)
			% Outputs hsnorm(C - eye(dimension)) where C is the matrix of 
			% inner products between basis elements. I.e. this function 
			% provides a single number describing how orthornormal the 
			% basis is. The basis is completely
			% orthonormal if this function returns 0.
			
			if isempty(self.basis)
				error('No basis has been input yet');
			end
			
			if self.iphs
				% if we are using the hs inner product, do this more 
				% efficiently than below
				B = self.standardform;
				x = hsnorm(B'*B - eye(self.dimension));
			else
				% the following is generally very inefficient
				% calculate the inner product of pairs of vectors
				B = zeros(self.dimension);
				for k = 1:self.dimension
					% start the l loop at k since the ip is symetric
					for l = k:self.dimension
						B(k,l) = self.ip(self.be(k), self.be(l));
					end
				end
				% populate the lower triangle with the conjugates of the
				% upper
				B = B + triu(B,1)';
				% return the desired quantity
				x = hsnorm(B - eye(self.dimension));
			end
						
		end

	end
	
end
