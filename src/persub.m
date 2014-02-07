function x = persub(p, perm, dims)
    % Permutes the order of subsystems in tensor product space
    %
    % Arguments:
    %	- p:		The square matrix or column vector to permute the subsystems of
    %	- perm:		The permutation to perform.
    %	- dims:		The dimensions of the factor spaces
    %
    % Outputs:
    %	- x:		The correct permutation
    %
    % Usage Example:
    %	p0 = tensor(X, Y, I, Z);
    %	% Switch the middle subsystems of this 4 qubit system:
    %	p1 = permuteSubsystem(p, [1 3 2 4], [2 2 2 2]);
    %   % Now p1 should be equal to tensor(X, I, Y, Z)
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


% check arguments
n = length(dims);
d = size(p);

% check for input errors
if length(perm) ~= n
  error('Number of subsystems in perm and dims should be equal');
end
if sort(perm) ~= 1:n
  error('perm is not a valid permutation, it should contain all numbers between 1 and %d inclusive', n);
end
if length(p) ~= prod(dims)
  error('Total dimension in dim does not match state p; one should have prod(dim)=length(p)')
end

if length(dims) <= 1
	x = p;
elseif min(d) == 1
	% we have a state vector
	perm = n+1-perm([end:-1:1]);
	x=reshape(p,dims(end:-1:1));
	x=permute(x,perm);
	x = reshape(x,d);
elseif d(1) == d(2)
	% density matrix
	perm = n+1-perm([end:-1:1]);
	perm = [perm,n+perm];
	x = reshape(permute(reshape(p,[dims(end:-1:1),dims(end:-1:1)]),perm),d);
else
	error('The input matrix should be a 1D matrix, or a square matrix');
end
