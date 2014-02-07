function b = ispositive(A, thresh)
    % Tests whether A is a positive semi-definite matrix
    %
    % Arguments:
    %	A:      a square 2D array
    %	thresh: (optional; default 1e-12) The threshhold for considering the
    %	diagonal entries to be real. See code for details.
    %
    % Outputs:
    %   b:      true if A is positive semi-definite, false otherwise
    %
    % Usage Example:
    %
    %   % make a random 5x5 complex matrix
    %   A = irand(5);
    %   % this will almost always output 0:
    %   ispositive(A)
    %   % this will always output 1:
    %   ispositive(A'*A)
    %	 this will always output 1:
    %   ispositive(Random.densitymatrix(100))

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


    if ~isnumeric(A) || length(size(A)) ~= 2 || size(A,1) ~= size(A,2)
        error('Expecting 2D square array');
	end
	
	if nargin < 2
		thresh = 1e-12;
	end
    
	% attempting cholesky factorization is apparently a fast way to test
	% for positivity. But chol complains even if A has tiny imaginary parts
	% on the diagonal. So run chol on A with the diagonal realified if we
	% deam the imaginary part small enough
	D = diag(A);
	if max(abs(imag(D))) > thresh
		b = false;
	else
		[~,p] = chol(A-diag(D)+diag(real(D)));
		b = p==0;
	end

end
