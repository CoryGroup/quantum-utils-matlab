classdef DFS
	% An (abstract) class for Decoherence Free Subsystems

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
		name			% A human-readable string to name a DFS instance
		subsystems		% A cell array of instances from the Basis class
	end
	
	properties (Dependent)
		physicaldim		% The number of dimensions the physical system's Hilbert space has
		logicaldim		% The number of logical dimensions that are protected (so logicaldim <= physicaldim)
		nsystems		% The number of subsystems (so if n=1, you have yourself a noiseless subspace)
		allsystems		% put all bases into one big 3D array
	end
	
	methods
		function self = DFS(S, name)
			% constructor
			if nargin > 0
				self.subsystems = S;
			end
			if nargin > 1
				self.name = name;
			else
				self.name = 'Decoherence Free Subsystem';
			end
		end
				
		% begin get and set methods
		function dim = get.physicaldim(self)
			if isempty(self.subsystems)
				error('No subsytems present.');
			end
			dim = prod(self.subsystems{1}.size);
		end
		function dim = get.logicaldim(self)
			if isempty(self.subsystems)
				error('No subsytems present.');
			end
			dim = self.subsystems{1}.dimension;
		end
		function n = get.nsystems(self)
			if isempty(self.subsystems)
				error('No subsytems present.');
			end
			n = length(self.subsystems);
		end
		function B = get.allsystems(self)
			B = zeros(self.physicaldim, self.logicaldim, self.nsystems);
			for k = 1:self.nsystems
				B(:,:,k) = self.subsystems{k}.basis;
			end
		end
		function self = set.subsystems(self, S)
			if ~iscell(S)
				error('The subsystem should be a cell array of Basis classes');
			end
			if length(S)+1 ~= sum(size(S))
				error('The subsystem should be a 1D cell array of Basis classes');
			end
			y = [S{1}.size S{1}.dimension];
			for k = 1:length(S)
				if ~isa(S{k}, 'basis.Basis')
					error('Entry %d of S is not an instance of the Basis class', k);
				end
				x = [S{k}.size S{k}.dimension];
				if k > 1 && sum(x-y) ~= 0
					error('Each basis must have the same dimension and size');
				end
			end
			self.subsystems = S;	
		end
		% end get and set methods
		
	end
	
	methods
		function X = makeLogicalOperator(self, A)
			% turns an operator A on logical space into an operator X on
			% physical space
			if ~isnumeric(A) || length(size(A)) ~= 2
				error('Unexpected input');
			end
			if length(A) > self.logicaldim
				error('Not enough logical dimensions');
			end
			
			X = zeros(self.physicaldim);
			
			for k = 1:size(A,1)
				for l = 1:size(A,2)
					for s = 1:self.nsystems
						v = self.subsystems{s}.be(l);
						w = self.subsystems{s}.be(k);
						X = X + A(k,l)*v*w';
					end
				end
			end
		end
		function display(self)
			% display's the DFS nicely
			
			% first make a box with the dimensions etc.
			width = 60;
			lines{1} = 'horizontalrule';
			lines{2} = {sprintf('Overview of "%s"', self.name)};
			lines{3} = 'horizontalrule';
			lines{4} = {sprintf('    nsystems: %d', self.nsystems)};
			lines{5} = {sprintf('  logicaldim: %d', self.logicaldim)};
			lines{6} = {sprintf(' physicaldim: %d', self.physicaldim)};
			lines{7} = 'horizontalrule';
			for k = 1:length(lines)
				if strcmp(lines{k}, 'horizontalrule')
					fprintf('%s\n', '-'*ones(1,width));
				else
					str = lines{k}{1};
					str = ['| ' str ' '*ones(1,width-length(str)-3) '|'];
					disp(str);
				end
			end
			fprintf('\n');
			
			% if our physical size is a power of two, use the computational
			% basis, otherwise, use a column basis
			numqubits = log2(self.physicaldim);
			if numqubits == round(numqubits)
				bas = basis.ComputationalBasis(numqubits);
			else
				bas = basis.ColumnBasis(self.physicaldim);
			end
			
			% then loop through the systems and print oout each state
			for k = 1:self.nsystems
				for l = 1:self.logicaldim
					fprintf('Subsystem %d, Basis Element %d\n', k, l);
					disp(bas.expandToStr(self.subsystems{k}.be(l),'table'));
				end
			end
		end
		function d = dual(self)
			% returs a new dfs whose logical and syndrome spaces have been
			% switched
			swap = permute(self.allsystems, [1 3 2]);
			B = cell(1,self.logicaldim);
			for k = 1:self.logicaldim
				B{k} = basis.ONBasis(reshape(swap(:,:,k), ...
					[self.physicaldim 1 self.nsystems]));
			end
			d = dfs.DFS(B);
		end
		function self  = rotate(self,UA,UB)
			B = 0;
			for k = 1:self.nsystems
				self.subsystem{k}.basis = self.subsystem{k}.basis*UB;
			end
		end
	end
	
end
