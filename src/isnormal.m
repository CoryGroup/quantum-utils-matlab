function b = isnormal(A, thresh)
    % Tests whether A is a normal matrix
    %
    % Arguments:
    %	A:       a square 2D array
    %	thresh:  (optional; default 1e-10) the threshhold level for considering
    %			 norm(A*A'-A'*A) to be 0
    %
    % Outputs:
    %   b:      true if A is normal, false otherwise
    %
    % Usage Example:
    %
    %   % make a random 5x5 complex matrix
    %   A = irand(5);
    %   % this will almost always output 0:
    %   isnormal(A)
    %   % this will always output 1:
    %   isnormal(A+A')

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


	if nargin == 1
		thresh = 1e-10;
	end
    if ~isnumeric(A) || length(size(A)) ~= 2 || size(A,1) ~= size(A,2)
        error('Expecting 2D square array');
	end
    
    % maybe there's a faster way to do this:
    b = pnorm(A*A'-A'*A)<thresh;

end
