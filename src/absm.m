function absA = absm(A)
    % Computes the absolute value of a matrix. If the matrix is normal, this 
    % is equivalent to taking the absolute value of the eigenvalues of A.
    %
    % Arguments:
    %	- A:	A 2D array
    %
    % Outputs:
    %	- absA:	The absolute value of A
    %	
    %
    % Usage Example:
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

    % Compute the absolute value of A
    absA = sqrtm(A*A');

end

