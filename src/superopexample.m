% superopexample - Demonstrates how to use the SuperOp class.


%------------------------------------------------------------------------------
% © 2014 Ian Hincks (ian.hincks@gmail.com).
% 
% This file is a part of the quantum-utils-matlab project.
% Licensed under the AGPLv3.
%------------------------------------------------------------------------------
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
%------------------------------------------------------------------------------

clear all;

% we make a new instance of the SuperOp class. this instance will store all
% information about the super-operator, and we can ask it to return the
% superoperator in any form we like

op = SuperOp();

% right now we havn't populated any data into our superoperator. we will do
% that now

% suppose we know the choi matrix is the following:
choimat = Random.densitymatrix(4);
disp('Our choi matrix is given by:');
choimat

% now we can put this into op:
op.choiform = choimat;

% if we ask op for the choi matrix, it will of course just spit the same
% thing out again
disp('Ask op for the Choi matrix:');
op.choimatrix

% to see all of the possible properties of op we can access, just type op
% without the semi-colon
disp('These are the properties of op that we can access');
op

% but we can ask op for any superoperator representation, and it will
% caculate it:
disp('The Kraus operators are given by:');
op.krausops{1}
disp('The Chi matrix in the column stacking basis is given by:');
op.changeChiBasis(basis.PauliONBasis(1));
op.chimatrix
disp('The SuperMatrix (Liouvillian) in the column stacking basis is given by');
op.liouvillematrix
disp('The Stinespring marix is given by');
op.stinespringpair{1}

% We could equally well start by populating op by providing the Kraus
% matrices:

% Make another SuperOp instance:
op2 = SuperOp();

% The Kraus matrices are stored as a 3D array, where the third dimension
% indexes which kraus matrix we are on. Below, we set the Kraus operators
% of op2 to be the Identity, and the Pauli X operator:
disp('Create a new SuperOp instance now');
op2.krausops = cat(3, Pauli.I/sqrt(2), Pauli.X/sqrt(2));

% now we can ask op2 for this superoperator in any form:
disp('The Choi matrix of op2 is given by:');
op2.choimatrix
disp('The Chi matrix of op2 in the column stacking basis is given by:');
op2.changeChiBasis(basis.PauliONBasis(1));
op2.chimatrix
disp('The SuperMatrix (Liouvillian) of op2 in the column stacking basis is given by');
op2.liouvillematrix
disp('The Stinespring marix of op2 is given by');
op2.stinespringpair{1}

% Finally, let's see how to act on states. We use the "act" command.
% First, let's make a density matrix:
rho = [1 0; 0 0];
disp('Our density matrix is given by');
rho

% and now lets act on it with op:
disp('After applying op we get:');
op.act(rho)

% and now lets act on it with op2:
disp('After applying op2 we get:');
op2.act(rho)
