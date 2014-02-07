function N = pnorm(A,p)
    % Computes the p-norm of A. If A is a vector, this is the standard p-norm.
    % If A is a matrix, this is the Schatten p norm. For the infinity norms,
    % use p=Inf
    %
    % Arguments:
    %	- A:	A vector or matrix
    %	- p:	(optional) A positive integer, or Inf. If p is not present, the
    %			2-norm is assumed
    %
    % Outputs:
    %	- N:	The p-norm of A
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


	% Check for errors
	if ~isnumeric(A)
		error('expecting numerical input');
	end
	
	% make p=2 the default
	if nargin == 1
		p = 2;
	end

	if sum(size(A)) == max(size(A)) + 1
		% we have a vector
		N = vectorpnorm(A, p);
	elseif length(size(A)) == 2
		% we have a 2D array
		if p==2
			% we have an efficient method if p=2
			N = sqrt(trace(A'*A));
		else
			% otherwise, compute the p-norm of the singular values of A
			N = vectorpnorm(svd(A), p);
		end
	else
		% we have something else
		error('Unexpected input size of matrix');
	end
	
	
	function x = vectorpnorm(v,p)
		% takes the p-norm of the vector v
		if p > 0 && p < Inf
			x = sum(abs(v).^p).^(1/p);
		else
			x = max(abs(v));
		end
	end

end
