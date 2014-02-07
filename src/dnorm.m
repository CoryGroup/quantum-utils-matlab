function dn = dnorm(op)
    % Computes the diamond norm of a superoperator
    %
    % Arguments:
    %	- op:	an instance of the actions.Action class
    %
    % Outputs:
    %	- dn:	the diamond norm of op
    %	
    %
    % Usage Example:
    %
    %	% make a random mixed unitary channel acting on 2 qubits
    % 	op_rand = Random.mixedunitary(4,3);
    % 	% make the identity superoperator
    % 	op_eye = SuperOp(eye(4), 'krausops');
    % 	% now compute the diamond norm of their distance
    % 	dist = dnorm(op_rand-op_eye)

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

if isa(op, 'actions.Action')
	error('The actions.Action class is no longer maintained; switch to the SuperOp class (it''s much nicer anyways.');
end
if ~isa(op, 'SuperOp')
	error('The input must be a member of the SuperOp class');
end

% get the Stinespring operators and relevent integers
A = op.stinespringpair{1};
B = op.stinespringpair{2};
n = op.inputdim;
m = op.outputdim;
t = op.stinespringtracedim;

% so we don't have to keep recomputing it
BB = B*B';

% we will use a semidefinite program, so make sure CVX is installed
checkcvx;

usecvx('begin');

% the sdp
cvx_precision high
cvx_begin sdp quiet
	variable X(m*t,m*t) hermitian
	variable rho(n,n) hermitian
	maximize trace(BB*X)
	subject to
		partialtrace(X-A*rho*A', m, t) == zeros(t)
		trace(rho) == 1
		X >= 0;
		rho >= 0;
cvx_end
dn = real(sqrt(cvx_optval));

usecvx('end');


	
end

function x = partialtrace(a, dimtraceout, dimkeep)
	% traces out the first subsystem of a matrix a. see the function ptrace
	% for details.
	x = reshape(permute(reshape(a, [dimkeep dimtraceout dimkeep dimtraceout]),[1 3 2 4]),[dimkeep dimkeep dimtraceout^2]);
	x = sum(x(:,:,[1:dimtraceout+1:dimtraceout^2]),3);
end
