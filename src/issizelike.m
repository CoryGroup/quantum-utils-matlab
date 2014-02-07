function y = issizelike(x)
    % Checks to see if the input is a 1D array of positive integers, ie,
    % checks to see whether x is a valid size of an array
    %
    % Arguments:
    %	- x:	anything
    %
    % Outputs:
    %	- y:	outputs true (1) if x is a 1D array of positive integers, and 
    %			false (0) otherwise
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


	y = true;
	if ~isnumeric(x)
		% is x not numeric?
		y = false;
		return;
	end
	if ~isreal(x)
		% does x have imaginary part?
		y = false;
		return;
	end
	if min(abs(x)) < 1
		% does x consist of any numbers less than 1?
		y = false;
		return;
	end
	if sum(size(x)) ~= length(x) + 1
		% is x not 1D
		y = false;
		return;
	end
	if sum(abs(x-round(x))) ~= 0
		% is x made of integers?
		y = false;
		return;
	end
	
end
