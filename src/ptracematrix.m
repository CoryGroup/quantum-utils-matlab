function M = ptracematrix(traceout, dims)
    % The partial trace is a linear map, and as such, has a matrix form. This
    % is that matrix form with respect to the column stacking basis. (NOTE:
    % matrix form is a much more general function which can do the same thing.
    % Consider decapricating this function)
    %
    % Arguments:
    %	- traceout:	The subsystem(s) to trace out
    %	- dims:		The dimensions of the tensor spaces
    %
    % Outputs:
    %	- M:		The matrix form of ptrace, ie, a matrix M such that
    %				unvec(M*vec(X)) = ptrace(X, traceout, dims)
    %
    % See Also:
    %	ptrace, matrixform
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


	N = prod(dims);
	dimkeep = N/prod(dims(traceout));
	
	M = zeros(dimkeep^2, N^2);
	
	for k=1:N^2
		A = zeros(N);
		A(r(k,N),c(k,N)) = 1;
		A = ptrace(A, traceout, dims);
		M(:,k) = reshape(A, [dimkeep^2 1]);
	end
	
	function x = r(a, p)
		x = mod(a-1, p) + 1;
	end
	function x = c(a, p)
		x = floor((a-1)/p) + 1;
	end

end
