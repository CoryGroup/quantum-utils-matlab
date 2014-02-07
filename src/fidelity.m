function F = fidelity(P, Q)
    % Computes the fidelity of the absolute values of P and Q. Typically,
    % the inputs will be positive semi-definite, in which case the absolute 
    % value is redundant.
    %
    % Arguments:
    %	- P:		A (positive semi-definite) matrix
    %	- Q:	A (positive semi-definite) matrix
    %
    % Outputs:
    %	- F:		F(|P|, |Q|); the fidelity of |P| and |Q|
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



	% compute the square root of |P|
	sqrtP = sqrtm(absm(P));

	% now just use the definition, remembering to use |Q| instead of Q
	F = abs(trace(sqrtm(sqrtP*absm(Q)*sqrtP)));


end
