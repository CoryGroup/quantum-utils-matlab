classdef MatrixLRBasis < basis.ONBasis
	% A ON basis for rows by cols matrices, using the Left-to-Right
	% ordering convention

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
