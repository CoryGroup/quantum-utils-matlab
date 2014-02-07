classdef TextProgressBar < progressbar.ProgressBar
    % A text progress bar in the command prompt. Refreshes are done by taking
    % advantage of the char(8) backspace character.
    %
    % Example Usage:
    %
    % 	N=100;
    % 	t = progressbar.TextProgressBar();
    % 
    % 	t.initialize;
    % 	for k=1:N
    % 		pause(0.05);
    % 		t.display(k/N);
    % 	end
    % 
    % 	t.max_extra_length = 30;
    % 
    % 	t.initialize;
    % 	for k=1:N
    % 		pause(0.03);
    % 		t.display(k/N,sprintf('\nWe are at k=%d',k));
    % 	end

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
		width = 40				% the number of characters wide the progress bar is
		done_char = '*'			% the character to use for the 'done' portion of the bar
		notdone_char = '-'		% the character to use for the 'not done' portion of the bar
		bar_ends = '||'			% the characters to use as stoppers for the bar
		max_extra_length = 0	% the number of allowed extra characters
	end
	
	methods
		function self = TextProgressBar(max_extra_length)
			% the constructor
			if nargin >= 1
				self.max_extra_length = max_extra_length;
			end
		end
		function initialize(self)
			% draws the progress bar at 0%; this is necessary because we
			% need to draw it at least once without erasing previous
			% characters.
			if self.max_extra_length == 0
				extrastr = '';
			else
				extrastr = ' '*ones(1,self.max_extra_length);
			end
			fprintf([self.createbar(0) '%s%s\n'], '%',extrastr);
			drawnow;
		end
		function display(self, fraction, extrastr)
			% Draws the progress bar, and erases the old one
			%	- fraction:	A number between 0 and 1
			%	- params: (optional; default char(10)) An extra string to
			%				append to. It will be chopped of after
			%				max_extra_length characters. Your string should
			%				not contain escape strings, or else its length
			%				will be miscalculated.
			if self.max_extra_length == 0 || nargin < 3
				extrastr = '';
			else
				extrastr = extrastr(1:min(end,self.max_extra_length));
			end
			extrastr = [extrastr ' '*ones(1,self.max_extra_length-length(extrastr))];
			fraction = min(max(real(fraction),0),1);
			bar = self.createbar(fraction);
			erase = ['' char(8)*ones(1,length(bar)+length(extrastr)+2)];
			fprintf([erase bar '%s' extrastr '\n'], '%');
			drawnow;
		end
	end
	
	methods (Access=private)
		function bar = createbar(self,fraction)
			% prints the bar and the percent done, except the percent sign
			done = round(self.width*fraction);
			done_str = self.done_char*ones(1, done);
			notdone_str = self.notdone_char*ones(1, self.width-done);
			bar = sprintf([self.bar_ends done_str notdone_str self.bar_ends '%3d'],round(fraction*100));
		end
	end
	
end
