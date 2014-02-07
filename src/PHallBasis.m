classdef PHallBasis < handle
    % A class for computing P. Hall Bases. Basically, you give it some strings,
    % and it will spit out more strings which tell which elements are in the P.
    % Hall Basis.
    %
    % Usage Example:
    %
    % % Let's make a P. Hall Basis on three symbols
    % phb = PHallBasis({'A','B','C'});
    % % Let's add another commutation function
    % phb.addCommutationFunction(@(a,b) strcat('c(',a,',',b,')'));
    % % Now get the elements up to depth 3 using the standard commutation
    % % convention
    % phb.getCommsUntilDepth(3)
    % % or we can use the commutation function we entered above:
    % phb.getCommsUntilDepth(3,2)
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

	
	properties
		symbols			% A 1D cell array of strings denoting the symbols in your basis
	end
	
	properties (Access=private)
		phallbasis		% A structure array which stores all of the P Hall Basis information. See the method addDepthLayer for details
		depthtracker	% An array keeping track of where the different depths in phallbasis are stored. See the method addDepthLayer for details.
		commutefcns		% A 1D cell array of function handles to functions which accept two strings and return a string. These functions specify "how to commute strings". The default value is {@(s1,s2) strcat('[',s1,',',s2,']')}
	end
	
	properties (Dependent)
		latestdepth		% The depth that has been calculated so far
		latestlength	% How many elements are in the basis so far
		numcommutefcns	% The number of commutations functions
	end
	
	%----------------------------------------------------------------------
	%  Constructor
	%----------------------------------------------------------------------
	methods
		function self = PHallBasis(symbols)
			% Constructs an instance of PHallBasis. "symbols" is a 1D array
			% of strings specifying the strings you want to represent your
			% lie algebra generators. This input is obligatory.
			self.symbols = symbols;
			self.phallbasis = cellfun(@(x) PHallBasis.newentry({x}, 1, 0), self.symbols);
			self.depthtracker = [1,length(symbols)];
			self.commutefcns = {@(s1,s2) strcat('[',s1,',',s2,']')};
		end
	end
	
	%----------------------------------------------------------------------
	%  Set and Get Methods
	%----------------------------------------------------------------------
	methods
		function set.symbols(self, symbols)
			if ~iscell(symbols) || sum(size(symbols)) - length(symbols) - 1 ~= 0 || sum(cellfun(@ischar, symbols))-length(symbols) ~= 0
				error('Expecting symbols to be a 1D cell of strings.');
			end
			self.symbols = symbols;
		end
		function cd = get.latestdepth(self)
			cd = self.phallbasis(end).depth;
		end
		function l = get.latestlength(self)
			l = length(self.phallbasis);
		end
		function n = get.numcommutefcns(self)
			n = length(self.commutefcns);
		end
	end
	
	%----------------------------------------------------------------------
	%  Public Methods
	%----------------------------------------------------------------------
	methods
		function comms = getCommsAtDepth(self, depth, whichcommute)
			% Returns a cell array of strings containing the commutations
			% at the given "depth". "whichcommute" specifies which
			% commutation function to use. The default value is 1, which
			% will usually be @(s1,s2) strcat('[',s1,',',s2,']')
			
			if nargin < 3
				whichcommute = 1;
			end
			
			if ~issizelike(whichcommute) || numel(whichcommute) > 1 || whichcommute > self.numcommutefcns
				error('"whichcommute" is expected to be a positive interger between 1 and numcommutefcns');
			end
			
			% first make sure that phallbasis has the desired depth stored
			self.updateToDepth(depth);
			
			% and then return the desired strings
			depthstartloc = self.depthtracker(depth,1);
			depthstoploc = self.depthtracker(depth,2);
			comms = arrayfun(@(x) x.str{whichcommute}, self.phallbasis(depthstartloc:depthstoploc), 'UniformOutput', false);
		end
		function comms = getCommsUntilDepth(self, depth, whichcommute)
			% Returns a cell array of strings containing the commutations
			% up until, and including, the given "depth". "whichcommute"
			% specifies which commutation function to use. The default
			% value is 1, which will usually be 
			% @(s1,s2) strcat('[',s1,',',s2,']')
			
			if nargin < 3
				whichcommute = 1;
			end
			
			if ~issizelike(whichcommute) || numel(whichcommute) > 1 || whichcommute > self.numcommutefcns
				error('"whichcommute" is expected to be a positive interger between 1 and numcommutefcns');
			end
			
			% first make sure phallbasis has all of the desired depths
			% stored
			self.updateToDepth(depth);
			
			% and then return the desired strings
			comms = arrayfun(@(x) x.str{whichcommute}, self.phallbasis, 'UniformOutput', false);
		end
		function addCommutationFunction(self, fcn)
			% adds a function to the list of commutation functions
			if ~isa(fcn, 'function_handle') || nargin(fcn) ~= 2
				error('Expecting a handle to a function with two inputs (should take two strings and return a string).');
			end
			self.commutefcns{end+1} = fcn;
			self.reset();
		end
		function removeCommutationFunction(self, num)
			% removes the num'th function from commutefcns
			if ~issizelike(num) || num > self.numcommutefcns
				error('Expecting "num" to be a positive integer from 1 to numcommutefcns');
			end
			self.commutefcns(num) = [];
			self.reset();
		end
	end
	
	%----------------------------------------------------------------------
	%  Private Methods
	%----------------------------------------------------------------------
	methods (Access=private)
		function updateToDepth(self, depth)
			% if it has not already been done, populates phallbasis to
			% the given depth
			if ~issizelike(depth) || numel(depth) > 1
				error('Expecting depth to be a positive integer');
			end
			while self.latestdepth < depth
				self.addDepthLayer();
			end
		end
		function addDepthLayer(self)
			% this function is the meat of the algorithm. it takes phallbasis
			% and adds all the commutators of the next depth to it.
			
			% phallbasis is a structure array where the structures have three properties:
			%	str:			a cell array of string of the commutation,
			%					one element for each member of commutefcns
			%	depth:			the depth of the commutation
			%	leftcommpos:	the index of phallbasis which stores the
			%					left element of the commutation. This
			%					doesn't exist at depth 0, so we just set it
			%					to 0
			
			% depth tracker keeps track of which entries of phallbasis are
			% at which depth. depthtracker(k,1) is where the commutations
			% of depth k start in phallbasis, and depthtracker(k,2) is
			% where the commutations of depth k stop in phallbasis. Yes,
			% there is a bunch of redundancy in the information it stores,
			% but it makes the code easier to follow, and going past depth
			% 20 will likely never happen with this code, so this matrix
			% will always be tiny anyways

			startinglength = self.latestlength;
			startingdepth = self.latestdepth;
			
			numc = self.numcommutefcns;

			% we want to make commutations of depth startingdepth+1. so the
			% depth in the left part of the commutation plus the depth in
			% the right part of the commutation should sum to this. of
			% course we want leftdepth<=rightdepth, hence the ceil
			for leftdepth = 1:ceil(startingdepth/2)
				% now rightdepth+leftdepth=startingdepth+1
				rightdepth = startingdepth - leftdepth + 1;

				% now we double-loop over i,j through all of the entries in
				% phallbasis = {B1,B2,B3,B4,...} and examine [Bi,Bj] where
				% Bi has depth leftdepth, and Bj has right depth. If
				% leftdepth~=rightdepth, then leftdepth<rightdepth, so that
				% i<j is guaranteed. but if leftdepth==rightdepth, we
				% explictly add in i<j.
				if leftdepth == rightdepth
					for i = self.depthtracker(leftdepth,1):self.depthtracker(leftdepth,2)
						for j = i+1:self.depthtracker(rightdepth,2)
							Bi = self.phallbasis(i);
							Bj = self.phallbasis(j);
							if PHallBasis.meetscriteria(i, Bj)
								% we have met the criteria for [Bi,Bj] to be in
								% the basis, so add it. but first, we loop
								% through all of the commutation functions
								% and take the string commutation
								commutationstrings = arrayfun(@(n) self.commutefcns{n}(Bi.str{n},Bj.str{n}), 1:numc, 'UniformOutput', 0);
								self.phallbasis(end+1) = PHallBasis.newentry(commutationstrings, startingdepth+1, i);
							end
						end
					end
				else
					for i = self.depthtracker(leftdepth,1):self.depthtracker(leftdepth,2)
						for j = self.depthtracker(rightdepth,1):self.depthtracker(rightdepth,2)
							Bi = self.phallbasis(i);
							Bj = self.phallbasis(j);
							if PHallBasis.meetscriteria(i, Bj)
								% we have met the criteria for [Bi,Bj] to be in
								% the basis, so add it
								commutationstrings = arrayfun(@(n) self.commutefcns{n}(Bi.str{n},Bj.str{n}), 1:numc, 'UniformOutput', 0);
								self.phallbasis(end+1) = PHallBasis.newentry(commutationstrings, startingdepth+1, i);
							end
						end
					end
				end
			end

			% don't forget to update depth tracker
			endinglength = self.latestlength;
			self.depthtracker(startingdepth+1,:) = [startinglength+1,endinglength];

		end
		function reset(self)
			% removes all depths computed so far (resets phallbasis to be
			% the initial symbols, and depthtracker back to one depth)
			for k = 1:self.depthtracker(1,2)
				self.phallbasis(k) = PHallBasis.newentry(repmat({self.phallbasis(k).str{1}},1,self.numcommutefcns), 1, 0);
			end
			self.phallbasis = self.phallbasis(1:self.depthtracker(1,2));
			self.depthtracker = self.depthtracker(1,:);
		end
	end
	
	%----------------------------------------------------------------------
	%  Private Static Methods
	%----------------------------------------------------------------------
	methods (Access=private,Static)
		function b = meetscriteria(i, Bj)
			% the third rule of a commutation being in the p hall basis is
			% given by this
			b = (Bj.depth==1) || (Bj.depth > 1 && Bj.leftcommpos <= i);
		end
		function n = newentry(str, depth, leftcommpos)
			% just facilitates making structures we want, nothing special
			n.str = str;
			n.depth = depth;
			n.leftcommpos = leftcommpos;
		end
	end
	
end
