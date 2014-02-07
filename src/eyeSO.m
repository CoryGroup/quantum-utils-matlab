function I = eyeSO(dim)
    % Creates the identity SuperOp
    %
    % Arguments:
    %	- dim:		The dimension of the input and output space
    %
    % Outputs:
    %	- S:		The identity SuperOp acting on dimension dim Hilbert space
    %	
    %
    % Usage Example:
    %
    %	I = eyeSO(3);
    % 

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



	if ~issizelike(dim) || length(dim) ~=1
		error('"dimsout" and "pos" are expected to be 1D arrays of positive integers.');
	end
	
	I = SuperOp(eye(dim^2), 'liouvilleform');

end
