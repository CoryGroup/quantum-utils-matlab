classdef Random
	% A static class for generating various random things

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

	
	methods (Static)
		function out = unitary(n)
			% Generate a random n-by-n unitary matrix, uniform over the
			% Haar measure
			if ~issizelike(n) || length(n) > 1
				error('Unexpected input');
			end
			[Q,R] = qr((randn(n)+1i*randn(n))/sqrt(2));
			out = Q*diag(diag(R)./abs(diag(R)));
		end
		
		function out = densitymatrix(n)
			% Generate a random n-by-n density matrix
			if ~issizelike(n) || length(n) > 1
				error('Unexpected input');
			end
			U = Random.unitary(n);
			prob = Random.probvector(n);
			out = U*diag(prob)*U';
		end
		
		function out = probvector(n)
			% Generate a random probability vector of length n
			if ~issizelike(n) || length(n) > 1
				error('Unexpected input');
			end
			out = rand(1,n);
			out = out/sum(out);
		end
		
		function out = mixedunitary(hilbertdim, num)
			% Generate a mixed unitary channel with num unitaries generated
			% randomly using Random.unitary
			if ~issizelike([hilbertdim num]) || length([hilbertdim num]) > 2
				error('Unexpected input');
			end
			krausops = zeros(hilbertdim, hilbertdim, num);
			probs = sqrt(Random.probvector(num));
			for k=1:num
				krausops(:,:,k) = probs(k)*Random.unitary(hilbertdim);
			end
			out = krausops;
			out = SuperOp(krausops, 'krausops');
		end
		
		function out = superoperator(hilbertdim)
			% Generate a random complex matrix (whose entries real and 
			% imaginary parts are chosen from the normal distribution) and
			% set this as the liouvillian in a SuperOp
			N = hilbertdim^2;
			out = SuperOp(randn(N)+1i*randn(N), 'liouvilleform');
		end
	end
	
end
