function logA = logmat(A)
    % Computes the logarithm of A. This is the same as matlab's logm, except we
    % are disabling the pesky message about non-principal logarithms whene A
    % has nonpositive eigenvalues
    %
    % Arguments:
    %	- A:	A 2D array
    %
    % Outputs:
    %	- logA:	One of the logarithms of A
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

	
	% Turn off the warning:
	warning('off','MATLAB:funm:nonPosRealEig');
	
	% Compute the logarithm
	logA = logm(A);
	
	% Turn on the warning:
	warning('on', 'MATLAB:funm:nonPosRealEig');

end
