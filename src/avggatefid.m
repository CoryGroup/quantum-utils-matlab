function f = avggatefid(U1, U2)
    % Computes the average gate fidelity between two unitary matrices
    %
    % Arguments:
    %	- U1:	The first unitary
    %	- U2:	The second unitary
    %
    % Outputs:
    %	- f:		The average gate fidelity between the two;
    %				|<U1,U2>|^2/(2^N) where N=length(U1)=length(U2)
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

	f = (abs(trace(U1'*U2))^2)/(2^size(U1,1));

end
