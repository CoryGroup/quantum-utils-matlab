function P = eigenprojector(A, a, thresh)
    % Computes the orthogonal projector onto the eigenspace of A with
    % eigenvalue a (within optional threshhold thresh).
    %
    % Arguments:
    %	- A:	 A normal matrix
    %	- a:	 The eigenvalue for which you want the corresponding projector
    %	- thresh (optional; default 1-e10) The tolerance allowed between
    %			 supplied eigenvalue a, and the computed eigenvalue
    %
    % Outputs:
    %	- P:	The orthogonal projector onto the eigenspace of A with
    %			eigenvalue a
    %
    % Usage Example:
    %
    % % find the symetric and anti-symetric projection operators for a pair of
    % % spin-1/2 particles
    % U = CommonOps.swap(2, 2, 1);
    % Psym = eigenprojector(U, 1);
    % Pasym = eigenprojector(U, -1);
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



	if nargin <= 2
		thresh = 1e-10;
	end
	if ~isnormal(A, thresh)
		warning('Calling eig on a non-normal operator');
	end
	
	% calculate spectrum
	[U D] = schur(A);
	D = diag(D);
	
	% get those eigenvalues in range
	E = (real(D) > real(a)-thresh).*(real(D) < real(a)+thresh);
	E = E.*(imag(D) > imag(a)-thresh).*(imag(D) < imag(a)+thresh);
	E = E==1;
	
	% now outer product and sum the relevant eigenvectors
	P = U(:,E)*U(:,E)';
	
end
