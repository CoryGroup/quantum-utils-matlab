classdef SuperOp < handle
    % Let C denote the set of complex numbers, and let X=C^n and Y=C^m for some
    % positive integers n and m. Then an instance of this class represents a
    % linear map from L(X) to L(Y), otherwise known as a superoperator. Note
    % that we are being more general than CPTP maps, which in some cases, is
    % very convenient. There are many equivalent ways to represent a
    % superoperator, and this class is an attempt to join them into one easy to
    % use format. One feature of this class is that it will make converting
    % between representations seamless.

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

	
	properties
		liouvilleform		% A cell array of the form {L, B}, where L is the superoperator in liouville operator space, and B is the basis used for your vectorization convention, which must be one of 'col', 'row', or of the form {BI, BO}, where BI and BO are instances of basis.Basis, and are the vectorizing and devectorizing bases respectively. This property, however, can be set by assigning it to a 2D array, in which case the 'col' convention is assumed.
		krausops			% A cell array containing two 3D arrays, the left and right kraus operators respectively, their third dimension indexing them. This property, however, can be set by assigning it to a single 3D array (say "K"), in which case, krausops will take the value {K, K}
		choiform			% A cell array of the form {C, n}, where C is the Choi matrix, and n is the dimension of the input Hilbert space. In the event that the dimensions of the input and output spaces are equal, you may set this property by simply assigning it to a matrix C
		chiform				% A cell array of the form {X, B}, where X is the Chi matrix, and B is the basis used; an instance of the basis.Basis class.
		stinespringpair		% A cell array with three elements, the left and right stinespring operators, and then the number of dimensions to be traced out. This property, however, can be set by assigning it to a cell array with two elements (say {A, n}), in which case, stinespring pair will take the form {A, A, n}
		handleform			% A cell array of the form {h, n, m} where h is a matlab handle to a superoperator (it is the user's responsibility to ensure it is linear) which takes n-by-n matrices and outputs m-by-m matrices. This property, however, can be set by assigning it to a cell array of the form {h,n} which will implicitly set m=n

		thresh = 1e-10		% The threshhold for various numerical approximations, such as deciding whether eigenvalues are 0
		
	end
	
	properties (Dependent)
		hasmap				% Whether or not a map is present
		
		inputdim			% The dimension of the input hilbert space
		outputdim			% The dimension of the output hilbert space
		
		iscp				% True iff the superoperator is completely positive
		istp				% True iff the superoperator is trace preserving
		iscptp				% True iff iscp and istp
		ishp				% True iff the superoperator is hermiticity preserving
		isunital			% True iff the superoperator is unital

		liouvillematrix		% The superoperator matrix liouville operator space
		liouvillebasis		% The vectorization convention used
		krausnum			% The number of krausoperators
		choimatrix			% The choi matrix
		choieigenvalues		% The eigenvalues of the choi matrix
		chimatrix			% The chi matrix	
		chibasis			% The Chi basis being used
		chibasisname		% The name property of the Chi basis
        stinespringtracedim % The number of dimensions to trace out in the stinespring representation
		matlabhandle		% A handle to the matlab function which implements the superoperator
		canonicalkraus      % The canonical Kraus representation constructed from the Choi matrix eigensystem
		
	end
	
	properties (Access=private)
		
		% the following are cached copies, so that they do not need to be
		% caluclated everytime they are used
		c_iscp
		c_istp
		c_ishp
		c_isunital
		c_liouvilleform
		c_liouvillebasis
		c_krausops
		c_choiform
		c_chiform
		c_chibasis
		c_stinespringpair
		c_handleform
	end
	
	properties (Access=protected)
		standardform		% the liouvillian under column stacking. this is chosen as the central form for two reasons: (1) because its the fasted way to act the map on a state; (2) because matlab is naturally good at column stacking through reshape
	end
	
	%----------------------------------------------------------------------
	%  Constructor
	%----------------------------------------------------------------------
	methods
		function self = SuperOp(value, variable) %#ok<INUSD>
		% The constructor let's you set any variable to any value. varibale
		% should be a string identifying which property of the SuperOp you
		% want to set, and value should be the desired value.
		% In addition to this, variable can be one of the following special
		% strings, with convenient purposes:
		%	- 'conjugation' --- Creates the SuperOp whose action is given
		%						by conjugation by value. So value in this
		%						case must be a 2D matrix
		%	- 'lindblad'    --- Creates the SuperOp which corresponds to
		%						the supergenerator with Hamiltonian 
		%						variable{1} and Lindblad operators in a 3D 
		%						matrix variable{2}
		%	
		% Usage Examples:
		%	% create a SuperOp with a coplex random liouville matrix
		%   op = SuperOp(irand(9), 'liouvilleform');
		%	% create a CP map by specifying a random positve Choi matrix
		%	op = SuperOp(Random.densitymatrix(4),'choiform');
		%	% create the superoperator swap gate on two qubits
		%	op = SuperOp(CommonOps.swap, 'conjugation');
			if nargin > 0
				if ~ischar(variable)
					error('The input "variable" is expected to be a string');
				end
				if strcmp(variable, 'conjugation')
					self.populateFromConjugation(value);
				elseif strcmp(variable, 'lindblad')
					self.populateFromLindblad(value{1},value{2});
				else
					eval(['self.' variable '=value;']);
				end
			end
		end
	end
	
	%----------------------------------------------------------------------
	%  Liouvillian Set and Get methods
	%----------------------------------------------------------------------
	methods
		function set.liouvilleform(self, mat)
			if iscell(mat) && numel(mat) == 2
				if ~isnumeric(mat{1}) || length(size(mat{1})) ~=2
					error('Expecting a 2D numeric input in the first element of the cell.');
				end
				if ~issizelike(sqrt(size(mat{1})))
					error('The width and height of the Liouvillian must be square numbers');
				end
				if ~iscell(mat{2})
					if ~strcmp(mat{2}, 'row') && ~strcmp(mat{2}, 'col')
						error('The second element of the cell must be col or row, or a pair of bases in a cell');
					end
				else
					if numel(mat{2}) ~= 2 || ~isa(mat{2}{1}, 'basis.Basis') || ~isa(mat{2}{2}, 'basis.Basis')
						error('The second element of the cell must be col or row, or a pair of bases in a cell');
					end
				end
				if iscell(mat{2}) && (~mat{2}{1}.issquare || ~mat{2}{2}.issquare)
					error('The basis must consist of square matrices');
				end
				if iscell(mat{2}) && (size(mat{1},2) ~= mat{2}{1}.dimension || size(mat{1},1) ~= mat{2}{2}.dimension) 
					error('The bases dimensions are not consistent with the provided Liouvillian');
				end
				self.resetAll();
				self.c_liouvilleform = mat; %#ok<*MCSUP>
			elseif isnumeric(mat)
				% we are being nice and allowing the basis to be omitted,
				% with the assumption of column stacking
				if length(size(mat)) ~=2
					error('Expecting a 2D numeric input.');
				end
				if ~issizelike(sqrt(size(mat)))
					error('The width and height of the Liouvillian must be square numbers');
				end
				self.resetAll();
				self.c_liouvilleform = {mat 'col'};
			else
				error('Expecting an input of the form {L,B} or L');
			end
			self.liouvilleToStandard();
		end
		function out = get.liouvilleform(self)
			if isempty(self.c_liouvilleform) && self.hasmap
				self.standardToLiouville();
			end
			out = self.c_liouvilleform;
		end
	end
		
	%----------------------------------------------------------------------
	%  Kraus Set and Get methods
	%----------------------------------------------------------------------
	methods
		function set.krausops(self, mat)
			if iscell(mat)
				if numel(mat) ~= 2
					error('Cell input should have two entries');
				end
				if length(size(mat{1})) > 3 || length(size(mat{2})) > 3 || ~isnumeric(mat{1}) || ~isnumeric(mat{2})
					error('The cell should contain 3D arrays');
				end
				if length(size(mat{1})) ~= length(size(mat{2}))
					error('Kraus operators must have the same size.');
				end
				if sum(abs(size(mat{1})-size(mat{2}))) ~= 0
					error('The left Kraus operators should have the same size and count as the right ones');
				end
				self.resetAll();
				self.c_krausops = mat;
			elseif isnumeric(mat)
				% we will be nice and accept a 3D array, so that the left
				% kraus operators are equal to the right ones (and we have
				% a CP map)
				if length(size(mat)) > 4
					error('Your Kraus operators should be a 3D array');
				end
				self.resetAll();
				self.c_iscp = true;
				self.c_krausops = {mat mat};
			else
				error('Unexpected input type');
			end
			self.krausToChoi();
			self.choiToStandard();
		end
		function out = get.krausops(self)
			if isempty(self.c_krausops) && self.hasmap
				self.standardToKraus();
			end
			out = self.c_krausops;
		end
	end
	
	%----------------------------------------------------------------------
	%  Choi Set and Get methods
	%----------------------------------------------------------------------
	methods
		function set.choiform(self, mat)
			if iscell(mat) && numel(mat) == 2
				if size(mat{1},1) ~= size(mat{1},2)
					error('Choi matrix must be square');
				end
				if ~issizelike(mat{2}) || numel(mat{2}) ~= 1
					error('The second element in the cell must be the dimension of the input Hilbert space.');
				end
				if mod(length(mat{1}), mat{2}) ~= 0
					error('The dimension of the input Hilbert space must divide the width of the Choi matrix');
				end
				self.resetAll();
				self.c_choiform = mat;
			elseif isnumeric(mat) && length(size(mat)) == 2
				if size(mat,1) ~= size(mat,2)
					error('Choi matrix must be square');
				end
				if ~issizelike(sqrt(size(mat)))
					error('Your Choi matrixs width is not a square number. Fix this, or enter it in the form {C,n} where C is the choi matrix and n is the dimension of the input Hilbert space.');
				end
				self.resetAll();
				self.c_choiform = {mat, sqrt(length(mat))};
			else
				error('Expecting an input of the form {C,n} or C, where C is the Choi matrix, and n is the dimension of the input Hilbert space');
			end
			self.choiToStandard();
		end
		function out = get.choiform(self)
			if isempty(self.c_choiform) && self.hasmap
				self.standardToChoi();
			end
			out = self.c_choiform;
		end
	end

	%----------------------------------------------------------------------
	%  Chi Set and Get methods
	%----------------------------------------------------------------------
	methods
		function set.chiform(self, mat)
			if ~iscell(mat)
				error('Expecting a cell array input');
			end
			if ~isnumeric(mat{1}) || length(size(mat{1})) ~=2 || size(mat{1},1) ~= size(mat{1},2)
				error('Expecting the first element of the cell to be a square 2D numeric input.');
			end
			if ~isa(mat{2}, 'basis.Basis')
				error('Expecting the second element of the cell to be a basis.Basis instance');
			end
			if length(mat{1}) ~= mat{2}.dimension
				error('The width of the Chi matrix should be the same as the basis dimension');
			end
			self.resetAll();
			self.c_chiform = mat;
			self.chiToChoi();
			self.choiToStandard();
		end
		function out = get.chiform(self)
			if isempty(self.c_chiform) && self.hasmap
				self.standardToChi();
			end
			out = self.c_chiform;
        end
        
        % The following setter is a convienence method only.
        function set.chimatrix(self, mat)
            self.chiform = {mat self.chiform{2}};
        end
	end
	
	%----------------------------------------------------------------------
	%  Stinespring Set and Get methods
	%----------------------------------------------------------------------
	methods
		function set.stinespringpair(self, mat)
			if  iscell(mat) && numel(mat) == 2
				% we will be nice and accept a cell array with only two
				% entries, it being accepted that the stinespring operators
				% are equal (and hence the map is CP)
				if length(size(mat{1})) ~= 2 || ~isnumeric(mat{1})
					error('The Stinespring operator should be a 2D arrays.');
				end
				if ~issizelike(mat{2}) || numel(mat{2}) ~= 1 || mod(size(mat{1},1),mat{2})
					error('The number of dimensions to trace out should be a positive integer which divides the dimension of the output space');
				end
				self.resetAll();
				self.c_iscp = true;
				self.c_stinespringpair = {mat{1} mat{1} mat{2}};
			elseif iscell(mat) && numel(mat) == 3		
				if length(size(mat{1})) ~= 2 || length(size(mat{2})) ~= 2 || ~isnumeric(mat{1}) || ~isnumeric(mat{2})
					error('The Stinespring operators should be 2D arrays.');
				end
				if sum(abs(size(mat{1})-size(mat{2}))) ~= 0
					error('The left Stinespring operator should have the same size right one');
				end
				if ~issizelike(mat{3}) || numel(mat{3}) ~= 1 || mod(size(mat{1},1),mat{3})
					error('The number of dimensions to trace out should be a positive integer which divides the dimension of the output space');
				end
				self.resetAll();
				self.c_stinespringpair = mat;
			else
				error('Expecting input to be cell array of the form {A,B,n} or {A,n}, where A and B are 2D matrices, and n is the number of dimensions to trace out.');
			end
			self.stinespringToStandard();
		end
		function out = get.stinespringpair(self)
			if isempty(self.c_stinespringpair) && self.hasmap
				self.standardToStinespring();
			end
			out = self.c_stinespringpair;
		end
	end
	
	%----------------------------------------------------------------------
	%  Matlab handle Set and Get methods
	%----------------------------------------------------------------------
	methods
		function set.handleform(self, mat)
			if iscell(mat) && numel(mat) == 2
				% we will be nice and accept a cell array with only two
				% entries, it being accepted that the input and output
				% spaces have the same size
				if ~isa(mat{1}, 'function_handle')
					error('The first element in the cell should be a matlab handle');
				end
				if ~issizelike(mat{2}) || numel(mat{2}) > 1
					error('The second element of the cell should be a positive integer');
				end
				self.resetAll();
				self.c_handleform = {mat{1} mat{2} mat{2}};
			elseif iscell(mat) && numel(mat) == 3
				if ~isa(mat{1}, 'function_handle')
					error('The first element in the cell should be a matlab handle');
				end
				if ~issizelike(mat{2}) || numel(mat{2}) > 1 || ~issizelike(mat{3}) || numel(mat{3}) > 1
					error('The second and third elements of the cell should be a positive integers');
				end
				self.resetAll();
				self.c_handleform = mat;
			else
				error('Expecting input to be cell array of the form {h,n} (so that m=n is implicit) or {h,n,m}, where h is a matlab handle to superoperator which takes n-by-n matrices and outputs m-by-m matrices');
			end
			self.handleToStandard();
		end
		function out = get.handleform(self)
			if isempty(self.c_handleform) && self.hasmap
				self.standardToHandle();
			end
			out = self.c_handleform;
		end
	end
	
	
	
	%----------------------------------------------------------------------
	%  Get methods for dependent variables
	%----------------------------------------------------------------------
	methods
		function out = get.hasmap(self)
			out = ~isempty(self.standardform);
		end
		
		function out = get.inputdim(self)
			out = sqrt(size(self.standardform,2));
		end
		function out = get.outputdim(self)
			out = sqrt(size(self.standardform,1));
		end
		
		function out = get.iscp(self)
			if ~self.hasmap
				error('No map has yet been input');
			end
			if isempty(self.c_iscp)
                % add a bit of identity to avoid slightly negative
                % eigenvalues from screwing us up
                self.c_iscp = ispositive(self.choimatrix + ...
                    self.thresh*eye(length(self.choimatrix)));
			end
			out = self.c_iscp;
		end
		function out = get.istp(self)
			if ~self.hasmap
				error('No map has yet been input');
			end
			if isempty(self.c_istp)
				self.c_istp = false;
				m = ptrace(self.choimatrix, 1, [self.outputdim, self.inputdim]);
				if pnorm(m-eye(self.inputdim)) < self.thresh
					self.c_istp = true;
				end
			end
			out = self.c_istp;
		end
		function out = get.iscptp(self)
			out = self.istp*self.iscp;
		end
		function out = get.isunital(self)
			if ~self.hasmap
				error('No map has yet been input');
			end
			if isempty(self.c_isunital)
				n = self.inputdim;
				m = self.outputdim;
				self.c_isunital = false;
				if pnorm(self.execute(eye(n))-eye(m)) < self.thresh
					self.c_isunital = true;
				end
			end
			out = self.c_isunital;
		end
		function out = get.ishp(self)
			error('this get method has not been implimented yet');
		end
		
		function out = get.liouvillematrix(self)
			out = self.liouvilleform{1};
		end
		function out = get.liouvillebasis(self)
			out = self.liouvilleform{2};
		end
		function out = get.krausnum(self)
			out = size(self.krausops{1}, 3);
		end
		function out = get.choimatrix(self)
			out = self.choiform{1};
		end
		function out = get.choieigenvalues(self)
            if self.inputdim ~= self.outputdim
                warning('eigenvalues only defined for square matrices, and your Choi matrix is not square (inputdim~=outputdim)');
                out = [];
            else
                out = eig(self.choimatrix); 
            end
		end
		function out = get.chimatrix(self)
			out = self.chiform{1};
		end
		function out = get.chibasis(self)
			out = self.chiform{2};
		end
		function out = get.chibasisname(self)
			out = self.chiform{2}.name;
        end
        function out = get.stinespringtracedim(self)
           out = self.stinespringpair{3}; 
        end
		function out = get.matlabhandle(self)
			out = self.handleform{1};
        end
        function out = get.canonicalkraus(self)
            op = SuperOp(self.choiform,'choiform');
            out = op.krausops;
        end
	end
	
	%----------------------------------------------------------------------
	%  Public methods
	%----------------------------------------------------------------------
	methods
		function out = act(self, in)
			% vec, multiply, unvec
			out = reshape(self.standardform*in(:),[self.outputdim,self.outputdim]);
		end
		function out = krausact(self, in)
			out = zeros(self.outputdim);
			for k=1:self.krausnum
				out = out + self.krausops{1}(:,:,k)*in*self.krausops{2}(:,:,k)';
			end
		end
		
		function populateFromConjugation(self, U)
			% Populates the operator's fields so that it is given by a
			% conjugation by U, ie, op(A) = U*X*U'
			if ~isnumeric(U) || length(size(U)) ~= 2
				error('You must conjugate by a 2D matrix');
			end
			self.resetAll();
			self.liouvilleform = tensor(conj(U),U);
			self.krausops = {U,U};
		end
		function populateFromLindblad(self,H,L)
			% Populates the operator's fields to result in the
			% supergenerator associated with the Hamiltonian H and the 3D
			% array of Lindblad operators L
			if ~isnumeric(H) || length(size(H)) ~= 2 || size(H,1)~=size(H,2)
				error('The Hamiltonian must be a 2D square matrix');
			end
			if ~isnumeric(L) || size(L,1)~=size(L,2)
				error('The Lindblad operators must be in the form of a 3D matrix, where the 3rd dimension indexes each Lindblad');
			end
			if size(L,1)~=size(H,1)
				error('Each Lindblad must have the same size as the Hamiltonian.');
			end
			self.resetAll();
			I = eye(size(H,1));
			S = 1i*(kron(H.',I)-kron(I,H));
			for k = 1:size(L,3)
				LL = L(:,:,k)'*L(:,:,k);
				S = S + kron(conj(L(:,:,k)),L(:,:,k))-(kron(LL.',I)+kron(I,LL))/2;
			end
			self.liouvilleform = S;
		end
		function changeLiouvilleBasis(self, B)
			% Updates the Liouvillian matrix to use new vectorization
			% bases. There must be a map present already. B can be one of:
			% (1) the string 'col' (input and output bases both columnize)
			% (2) the string 'row' (input and output bases both stack rows)
			% (3) {BI BO}, a cell with two bases, the input and output
			% vectorization conventions, instances of the basis.Basis class
			if ~self.hasmap
				error('You must enter a map before you can change the basis');
			end
			% not implemented yet
		end
		function changeChiBasis(self, B)
			% Updates the Chi matrix to use the new basis B. There must be
			% a map present already. B must be an instance of the
			% basis.Basis class
			% Usage example:
			% op = SuperOp();
			% op.liouvilleform = irand(4);
			% B = basis.PauliONBasis(1);
			% op.changeBasis(B);
			% op.chimatrix
			if ~self.hasmap
				error('You must enter a map before you can change the basis');
			end
			self.c_chiform = {B.inverse*self.choimatrix*B.standardform B};
		end
	end
	
	%----------------------------------------------------------------------
	%  Overloaded operator methods
	%----------------------------------------------------------------------
	methods
%		This can act a bit screwy, so maybe its best just to leave it out
% 		function X = subsref(op, s)
% 			% we overload the parentheses operator to call the act
% 			% function. this forces us to deal with the weird subsref
% 			% function, which simultaneously controls the '.' function, the
% 			% '()' function and the '{}' function
% 			switch s(1).type
% 			case '()'
% 				% we got parentheses, so call act
% 				X = op.act(s.subs{1});
% 			case '.'
% 				% we got the dot, so call whatever is necessary
% 				if length(s)>1
% 					X = op.(s(1).subs)(s(2).subs{:});
% 				else
% 					X = op.(s.subs);
% 				end
% 			otherwise
% 				error('Use the syntax op(X) to act the SuperOp op on the matrix X');
% 			end
% 		end
		function op = plus(op1, op2)
			% overload the "+" operation
			if op1.inputdim ~= op2.inputdim || op1.outputdim ~= op2.outputdim
				error('Superoperators must have the same size.');
			end
			op = SuperOp();
			op.liouvilleform = op1.standardform + op2.standardform;
		end
		function op = minus(op1, op2)
			% overload the "-" operation
			if op1.inputdim ~= op2.inputdim || op1.outputdim ~= op2.outputdim
				error('Superoperators must have the same size.');
			end
			op = SuperOp();
			op.liouvilleform = op1.standardform - op2.standardform;
		end
		function op = uplus(op1)
			% overload the "+" operation
			op = SuperOp();
			op.liouvilleform = op1.standardform;
		end
		function op = uminus(op1)
			% overload the unary "-" operation
			op = SuperOp();
			op.liouvilleform = -1*op1.standardform;
		end
		function op = mtimes(op1, op2)
			% overload the "*" operation (the composition of
			% superoperators or, scaling superoperators by a constant)
			isnum1 = isnumeric(op1) && numel(op1)==1;
			isnum2 = isnumeric(op2) && numel(op2)==1;
			isop1 = isa(op1, 'SuperOp');
			isop2 = isa(op2, 'SuperOp');
			if isop1 && isop2
				if op2.outputdim ~= op1.inputdim
					error('The output space of the right superoperator must be the input space of the left one.');
				end
				op = SuperOp();
				op.liouvilleform = op1.standardform*op2.standardform;
			elseif isop1 && isnum2
				op = SuperOp();
				op.liouvilleform = op1.standardform*op2;
			elseif isnum1 && isop2
				op = SuperOp();
				op.liouvilleform = op2.standardform*op1;
			else
				error('You must multiply a SuperOp with a SuperOp, or a SuperOp with a number');
			end
		end
		function op = mpower(op1,n)
			% overload the "^" operation (compose the map with itself n
			% times)
			op = SuperOp();
			op.liouvilleform = op1.standardform^n;
		end
		function b = ne(op1, op2)
			% overload the "~=" operation
			if op1.inputdim ~= op2.inputdim || op1.outputdim ~= op2.outputdim
				b = true;
			elseif pnorm(op1.standardform-op2.standardform)>min([op1.thresh,op2.thresh]);
				b = true;
			else
				b = false;
			end
		end
		function b = eq(op1, op2)
			% overload the "==" operation
			b = ~ne(op1,op2);
		end
		function op = ctranspose(op1)
			% overload the "'" operation. this outputs the adjoint
			% superoperator
			op = SuperOp();
			op.liouvilleform = op1.standardform';
		end
		function op = vertcat(varargin)
			% we use vertcat as the tensor product of superoperators
			
			% just take it one at a time. the tensor product of two
			% superoperators is the tensor product of their liouvillians,
			% along with a swap on two pairs of indices. it's easiest to
			% see in tensor network pictures (thanks Chris Wood...)
			M = varargin{1}.liouvillematrix;
			for k = 2:length(varargin)
				n = sqrt(size(M,2));
				m = sqrt(size(M,1));
				p = varargin{k}.inputdim;
				q = varargin{k}.outputdim;
				M = tensor(M, varargin{k}.liouvillematrix);
				M = reshape(M, [q q m m p p n n]);
				M = permute(M, [1 3 2 4 5 7 6 8]);
				M = reshape(M, [q*q*m*m p*p*n*n]);
			end
			op = SuperOp();
			op.liouvilleform = M;
		end
		function op = horzcat(varargin)
			% we use horzcat to multiply (ie compose) superoperators
			
			M = varargin{1}.liouvillematrix;
			for k = 2:length(varargin)
				M = M*varargin{k}.liouvillematrix;
			end
			op = SuperOp();
			op.liouvilleform = M;
		end
		function op = expm(op1)
			op = SuperOp();
			op.liouvilleform = expm(op1.standardform);
		end
	end
	
	%----------------------------------------------------------------------
	%  Private conversion methods
	%----------------------------------------------------------------------
	methods (Access=private)
		function liouvilleToStandard(self)
			if ischar(self.liouvillebasis) && strcmp(self.liouvillebasis, 'col')
				self.standardform = self.liouvillematrix;
			elseif ischar(self.liouvillebasis) && strcmp(self.liouvillebasis, 'row')
				% we need column stacking to row stacking: just a swap
				% operation does it
				n = sqrt(size(self.liouvillematrix, 2));
				m = sqrt(size(self.liouvillematrix, 1));
				self.standardform = reshape(permute(reshape(self.liouvillematrix, [m m n n]),[2 1 4 3]), [m^2, n^2]);
			else
				% the standardforms (or inverses thereof) of the bases are
				% conviently the correct change of basis matrices we need
				self.standardform = self.liouvillebasis{2}.standardform*self.liouvillematrix*self.liouvillebasis{1}.inverse;
			end
		end
		function krausToChoi(self)
			% this could probably be vectorized if speed is an issue
			C = zeros(numel(self.krausops{1}(:,:,1)));
			for k = 1:self.krausnum
				C = C + vec(self.krausops{2}(:,:,k))*vec(self.krausops{1}(:,:,k))';
			end
			self.c_choiform = {C, size(self.krausops{1}(:,:,1),2)};
		end
		function choiToStandard(self)
			% we need to do a column reshuffling, which turns out to be
			n = self.choiform{2};
			m = length(self.choimatrix)/n;
			self.standardform = reshape(permute(reshape(self.choimatrix, [m n m n]), [1 3 2 4]), [m^2 n^2]);
		end
		function chiToChoi(self)
			% use the standardform as a change of basis
			self.c_choiform = {self.chibasis.standardform*self.chimatrix*self.chibasis.inverse self.chibasis.size(2)};
		end
		function stinespringToStandard(self)
			% there's probably a better way to do this
			n = size(self.stinespringpair{1},2);
			m = size(self.stinespringpair{1},1)/self.stinespringpair{3};
			f = @(x) ptrace(self.stinespringpair{1}*x*self.stinespringpair{2}', 2, [m self.stinespringpair{3}]);
			self.standardform = matrixform(f, [n n], [m m]);
		end
		function handleToStandard(self)
			% matrix form does exactly what we want
			n = self.handleform{2};
			m = self.handleform{3};
			self.standardform = matrixform(self.matlabhandle, [n n], [m m]);
		end
		
		function standardToLiouville(self)
			% we use column stacking by default
			self.c_liouvilleform = {self.standardform 'col'};
		end
		function standardToKraus(self)
			% just reshape the singular vectors whose singular values are
			% non-zero (or the eigenvectors when self is CP)
			if self.inputdim~=self.outputdim
				warning('This conversion is not yet implemented for cases where the input and output dimensions are unequal');
			end
			if self.iscp
				[U S] = schur(self.choimatrix);
				V = U;
			else
				[U S V] = svd(self.choimatrix);
			end
			S = diag(S);
			U = U(:, S > self.thresh);
			V = V(:, S > self.thresh);
			S = S(S > self.thresh);
			if isempty(S)
				U = zeros(self.inputdim*self.outputdim,1);
				V = zeros(self.inputdim*self.outputdim,1);
				S = 0;
			end
			%	U = zeros(self.
			U = reshape(U*diag(sqrt(S)), [self.outputdim self.outputdim length(S)]);
			V = reshape(V*diag(sqrt(S)), [self.inputdim self.inputdim length(S)]);
			
			self.c_krausops = {U V};
		end
		function standardToChoi(self)
			% a column reshuffle
			n = self.inputdim;
			m = self.outputdim;
			self.c_choiform = {reshape(permute(reshape(self.standardform, [m n m n]), [1 3 2 4]), [m^2 n^2]) n};
		end
		function standardToChi(self)
			% use column stacking as the default basis
			% the chi matrix is a change of basis from the choi matrix
			B = basis.MatrixTBBasis(self.outputdim, self.inputdim);
			self.c_chiform = {B.inverse*self.choimatrix*B.standardform B};
		end
		function standardToStinespring(self)
			% derive them from summing over the kraus operators (which were
			% in turn taken from the svd of the choi matrix)
			A = zeros(self.outputdim*self.krausnum, self.inputdim);
			B = zeros(self.outputdim*self.krausnum, self.inputdim);
			for k = 1:self.krausnum
				e = zeros(self.krausnum, 1);
				e(k) = 1;
				A = A + tensor(self.krausops{1}(:,:,k),e);
				B = B + tensor(self.krausops{2}(:,:,k),e);
			end
			self.c_stinespringpair = {A B self.krausnum};
		end
		function standardToHandle(self)
			% hurrah for trivial conversions. although i'm a bit cautious
			% because of the handle class thing, so let's do a bit more
			% than just handle = @(x) self.act(x)
			n = self.inputdim;
			m = self.outputdim;
			A = self.standardform;
			handle = @(x) reshape(A*x(:), [m,n]);
			self.c_handleform = {handle n m};
		end
	end
	
	%----------------------------------------------------------------------
	%  Private housekeeping methods
	%----------------------------------------------------------------------
	methods (Access=private)
		function self = resetAll(self)
			self.c_iscp = [];
			self.c_istp = [];
			self.c_ishp = [];
			self.c_isunital = [];
			self.c_liouvilleform = [];
			self.c_krausops = [];
			self.c_choiform = [];
			self.c_chiform = [];
			self.c_stinespringpair = [];
			self.c_handleform = [];
		end
	end
	
	
end
