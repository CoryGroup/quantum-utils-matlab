function X = tensor(varargin)
    % A generalization of the matlab kron function; matrix kroneckers an 
    % arbitrary number of matrices together
    %
    % Arguments:
    %	- varargin:		A variable list of matrices
    %
    % Outputs:
    %	- PO:			The matrix kronecker of the input matrices
    % Usage Example:
    %	X  =Pauli.X;
    %	tensor(X,X,X,I,I,X)
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

if length(varargin) < 1,
	error('Please enter at least 1 Product Operator');
elseif length(varargin) == 1,
	X = varargin{1};
else
	X = varargin{1};
	for j = 2:length(varargin),
		X = kron(X, varargin{j});
	end
end

