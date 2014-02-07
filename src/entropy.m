function S = entropy(P, Q)
    % Computes either the entropy or the mutual entropy, depending on whether Q
    % is present in the input arguments. If P or Q have any non positive
    % eigenvalues, they are simply thrown out completely. Logs are taken in
    % base 2.
    %
    % Arguments:
    %	- P:		A (positive semi-definite) matrix
    %	- Q:		(optional) A (positive semi-definite) matrix
    %
    % Outputs:
    %	- S:		S(P) = -Tr(P*log(P))				if Q is absent
    %				S(P||Q) = -S(P)-Tr(P*log(Q))		if mode is 'relative' or 'r'
    % Remarks:
    %	If P or Q have any non positive eigenvalues, they are simply thrown 
    %	out completely.
    %
    % Usage Example:
    %
    %	The following tests joint concavity of relative entropy:
    %
    %	% Make some density matrices
    %	A = rand(10); B = rand(10); A = A*A'; B = B*B'; A = A/trace(A); B = B/trace(B);
    %	AA = rand(10); BB = rand(10); AA = AA*AA'; BB = BB*BB'; AA = AA/trace(AA); BB = BB/trace(BB);
    %	
    %	% Make a range of probabilities
    %	p = [0:0.01:1];
    %
    %	% Loop through and calculate both sides of the joint concavity
    %	% inequality
    %	S = zeros(1,length(p));
    %	T = zeros(1,length(p));
    %	for k=1:length(p)
    %		S(k) = entropy(p(k)*A+(1-p(k))*B,p(k)*AA+(1-p(k))*BB);
    %		T(k) = p(k)*entropy(A,AA) + (1-p(k))*entropy(B,BB);
    %	end
    %
    %	% Green is higher than red, as expected:
    %	plot(p,S,'r', p,T,'g'); axis([0,1,0,5])
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



	% Get dimension
	n = length(P);
	
	% Set a number we think is close enough to 0
	thresh = 1e-10;
		
	% check for error in shape
	if ~(sum(size(P)) == 2*n)
		error('Square input required');
	end

	if nargin == 1
		% Just compute the regular entropy
		
		% Find the eigenvalues
		p = eig(P);
		
		% Throw out the non-positive ones
		p = p(p>thresh);
		
		% Calculate shannon entropy of the positive eigenvalues
		S = -1*sum(p.*log2(p));
		
	elseif nargin == 2
		% We want the relative entropy
		
		% Check for dimension mismatches
		if sum(size(P)-size(Q)) > 0
			error('Dimension mismatch between P and Q');
		end
		
		% Get dimension
		n = length(P);
		
		% Find the eigenvalues/vectors
		[UP, p] = eig(P);
		[UQ, q] = eig(Q);
		p = diag(p);
		q = diag(q);
		
		% Create masks for 0 values
		pp = p>thresh;
		qq = q>thresh;
		
		% remove non-positive values, keeping length the same
		p = p.*pp;
		q = q.*qq;
		
		% Calculate part of trace(P*logQ), and then mask it
		s = p.'*(abs(UQ'*UP).^2);
		ss = (s>thresh);
		
		% In this case, we will be multiplying log0 by a finite number,
		% so the output will be infinity. Otherwise, everything should be
		% fine
		if sum(ss' & ~qq)
			warning('The kernel of Q is not in the kernel of P; outputting infinity');
			S = Inf;
			return;
		end
			
		
		% Calculate shannon entropy of the positive eigenvalues
		% That s*log2(q) = trace(P*logQ) is just an exercise in index
		% gymnastics
		S = sum(p(pp).*log2(p(pp))) - s*log2(q);
	end
		
end
