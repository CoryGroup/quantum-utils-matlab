classdef Pauli
	% A static class containing the Pauli matrices and a useful Pauli
	% tensoring function (parseString). See also the Basis class
	% PauliONBasis

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

	
	properties (Constant)
		I = [1 0; 0 1]		% The identity Pauli operator
		X = [0 1; 1 0]		% The X Pauli operator
		Y = [0 -1i; 1i 0]	% The Y Pauli operator
		Z = [1 0; 0 -1]		% The Z Pail operator
		P = [0 1; 0 0]		% The plus operator, (X+iY)/2
		M = [0 0; 1 0]		% The minus operator, (X+iY)/2
		U = [1 0; 0 0]		% The "up" projector, (I+Z)/2
		D = [0 0; 0 1]		% The "down" projector (I-Z)/2
		allpaulis = reshape([Pauli.I Pauli.X Pauli.Y Pauli.Z], 2, 2, 4)		% all of the Paulis; use method "p" to get them
		
		Si = eye(3);								% Spin-1 identity
		Sx = [0 1 0; 1 0 1; 0 1 0]/sqrt(2);			% Spin-1 Pauli X
		Sy = [0 -1i 0; 1i 0 -1i; 0 1i 0]/sqrt(2);	% Spin-1 Pauli Y
		Sz = [1 0 0; 0 0 0; 0 0 -1];				% Spin-1 Pauly Z
	end
	
	methods (Static)

		function matrixout = parseString(textin, debug)
			% Creates a matrix given a text input of the state. 
			%
			% Arguments:
			%	- textin:		A string of text to parse into a sum of paulis/comp basis 
			%					states use X,Y,Z for the paulis, and U,D for the up and 
			%					down 2x2 density matrices. See usage examples below.
			%	- debug:		Because of the simple and efficient way this is implemented, 
			%					the error messages caused by faulty text inputs will be 
			%					useless. So set the debug flag to 1 if you are having problems.
			%					The string that is output should be a valid	matlab command
			%
			% Outputs:
			%   - matrixout:	A matrix corresponding to the evaluation of the input string
			%
			% Usage Examples:
			%	The way the factors are formated is pretty forgiving. All of the following
			%	are valid:
			%		- mkstate('IIX+XII+IXI');			% No coefficient defaults to 1
			%		- mkstate('(1-i)*IIX - (1+i)YYY');	% * not necessary, but is
			%											allowed
			%		- mkstate('5UII - (pi/2 + 1/sqrt(i-1))ZZZ');	% will evaluate
			%														  built in constants 
			%														  and functions

			if nargin == 1
				debug = false;
			end
			
			% Okay, let's setup the Paulis and variations of
			X = Pauli.X;
			Y = Pauli.Y;
			Z = Pauli.Z;
			I = Pauli.I;
			U = [1 0; 0 0];
			D = [0 0; 0 1];
			P = Pauli.P;
			M = Pauli.M;

			% parse everything into a matlab command
			cmd = regexprep(textin, ...
					{'\s', ...				% remove all whitespace
					 '([IXYZUDPM])', ...		% add commas after these matches
					 '([IXYZUDPM,]+),' ...		% add tensor around this
					 '([^*^\+^\-])(tensor)'}, ...	% make sure tensor is preceded by
					{'', ...						% an operator (allows e.g. '5XIX')
					 '$1,', ...
					 'tensor($1)', ...
					 '$1*$2'});
				 
			if debug
				fprintf('%s\n', cmd);
			end

			% evaluate the command to get the output matrix
			eval(sprintf('matrixout = %s;', cmd));

		end
		function x = p(n)
			% Returns the n'th (mod 4) Pauli matrix, where p(0) = I, p(1) = X,
			% p(2) = Y, and p(3) = Z
			x = Pauli.allpaulis(:,:,mod(n,4)+1);
		end
		function j = toNum(input)
			% Outputs input mod 4 OR
			% uutputs 0, 1, 2, 3 with input 'I', 'X', 'Y', 'Z',
			% respectively
			if isnumeric(input)
				j = mod(input, 4);
			elseif input == 'I'
				j = 0;
			elseif input == 'X'
				j = 1;
			elseif input == 'Y'
				j = 2;
			elseif input == 'Z'
				j = 3;
			else
				error('Unexpected Pauli input');
			end			
		end
		function out = insert(n, pauli, k, varargin)
			% Puts the pauli'th pauli operator in the k'th spot in a tensor of
			% identities
			%
			% Arguments:
			%	- n;		The total number of qubits
			%	- pauli:	Which Pauli to insert. Can be an integer with the 
			%				same numbering as the method p, or one of 'X', 'Y', 
			%				'Z', or 'I'.
			%	- k:		A integer between 1 and n inclusive; where to put
			%				the Pauli
			%	- varargin: Specify more Pauli's too insert into the
			%				product in the form insert(n, pauli1, k1,
			%				pauli2, k2, pauli3, k3, ...)
			%
			% Outputs:
			%   - out:		A tensor product of n-1 identities and the pauli'th
			%				pauli, where the pauli is in the k'th spot
			%
			% Usage Examples:
			%	
			%	% The following will yeild x=y
			%	x = Pauli.insertSingle(4, 1, 2);
			%	y = Pauli.parseString('IXII');
			%
			%	% The following will yeild x=y
			%	x = Pauli.insertSingle(4, 1, 2, 'Y', 4);
			%	y = Pauli.parseString('IXIY');
			%
			%
			
			% allow for character Pauli input
			pauli = Pauli.toNum(pauli);
			
			if nargin > 3
				optargin = length(varargin);
				if mod(optargin, 2) ~= 0
					error('The variable length input must contain pairs of pauli operators along with their positions');
				end
				% put all the pauli positions into a vector
				k = [k varargin{2:2:optargin}];
				% next loop through the paulis and put them in a vector
				pauli = [pauli zeros(1, optargin/2)];
				for j = 1:optargin/2
					pauli(j+1) = Pauli.toNum(varargin{2*j-1});
				end
			end
			
			% check for k error
			if ~issizelike(k)
				error('One of your Pauli positions was not entered correctly');
			end
			if min(k) < 1 || max(k) > n
				error('k out of range');
			end
			if length(unique(k)) ~= length(k)
				error('Your Pauli positions must be unique');
			end
			
			% sort the positions
			[k ix] = sort(k);
			pauli = pauli(ix);
				
			% calculate the output
			out = eye(2^(k(1)-1));
			k = [k n+1];
			for j=1:length(pauli)
				out = tensor(out, Pauli.p(pauli(j)), eye(2^(k(j+1)-k(j)-1)));
			end
		end
		function out = JX(n)
			% Returns the X collective rotation generator on n qubits
			out = zeros(2^n);
			for k = 1:n
				out = out + Pauli.insert(n,1,k);
			end
		end
		function out = JY(n)
			% Returns the Y collective rotation generator on n qubits
			out = zeros(2^n);
			for k = 1:n
				out = out + Pauli.insert(n,2,k);
			end
		end
		function out = JZ(n)
			% Returns the Z collective rotation generator on n qubits
			out = zeros(2^n);
			for k = 1:n
				out = out + Pauli.insert(n,3,k);
			end
        end
        function out = JJ(n)
			% Returs the J-total operator for n-qubits
			JX = Pauli.JX(n);
			JY = Pauli.JY(n);
			JZ = Pauli.JZ(n);
			out = JX*JX + JY*JY + JZ*JZ;
        end
		function out = SpinX(S)
			% returns the 2S+1x2S+1 X spin operator
			out = zeros(2*S+1);
			for m = 1:2*S+1
				for n = 1:2*S+1
				out(m,n)=sqrt(S*(S+1)-(S+1-m)*(S+1-n))*((m==n+1)+(m+1==n))/2;
				end
			end
		end
		function out = SpinY(S)
			% returns the 2S+1x2S+1 Y spin operator
			out = zeros(2*S+1);
			for m = 1:2*S+1
				for n = 1:2*S+1
				out(m,n)=1i*sqrt(S*(S+1)-(S+1-m)*(S+1-n))*((m==n+1)-(m+1==n))/2;
				end
			end
		end
		function out = SpinZ(S)
			% returns the 2S+1x2S+1 Z spin operator
			out = diag([S:-S:-1]);
		end
		function out = SpinP(S)
			% returns the 2S+1x2S+1 X+iY spin operator
			out = Pauli.SpinX(S)+1i*Pauli.SpinY(S);
		end
		function out = SpinM(S)
			% returns the 2S+1x2S+1 X+iY spin operator
			out = Pauli.SpinX(S)-1i*Pauli.SpinY(S);
		end
	end
	
end
