classdef ColumnBasis < basis.ONBasis
	% A ON basis for column vectors

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
