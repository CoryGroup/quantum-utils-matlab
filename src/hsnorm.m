function x = hsnorm(A)
    % Computes the Hilbert-Schmidt norm (the norm induced by the
    % Hilbert-Schmidt inner-product) of a matrix. Sometimes also called the
    % Frobenius norm. Remark that hsnorm(A) = pnorm(A,2) for all A, but this
    % function is much faster.
    %
    % Arguments:
    %	- A:		A matrix
    %
    % Outputs:
    %	- x:		Returns sqrt(hs(A,A)). See hs.m
    %
    % Usage Example:
    %	hsnorm(rand(10))
    %	hsnorm(rand(1,10))
    %	hsnorm(rand(10,1))
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



	% check inputs for errors
	if ~isnumeric(A)
		error('Numeric input expected');
	end

	% just use the norm induced by the hs function
	x = sqrt(hs(A,A));


end
