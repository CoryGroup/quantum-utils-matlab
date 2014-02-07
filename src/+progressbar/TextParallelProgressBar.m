classdef TextParallelProgressBar < progressbar.ProgressBar
% A text progress bar in the command prompt that works inside parfor loops.
% Gets around annoying parfor variable access by storing progress in a
% textfile. Refreshes are done by taking advantage of the char(8) backspace
% character.
%
% Example Usage:
%
% 	N=100;
% 	t = progressbar.TextParallelProgressBar(N);
% 
% 	t.initialize;
% 	parfor k=1:N
% 		pause(0.3);
% 		t.display;
% 	end
%
% 	t.max_extra_length = 30;
% 
% 	t.initialize;
% 	parfor k=1:N
% 		pause(0.3);
% 		t.display(sprintf('\nWe are at k=%d',k));
% 	end
%
%	% just deletes the text file, if you don't want it.
%	t.delete;
	
	properties
		steps					% the number of iterations in your parfor loop
		width = 40				% the number of characters wide the progress bar is
		done_char = '*'			% the character to use for the 'done' portion of the bar
		notdone_char = '-'		% the character to use for the 'not done' portion of the bar
		bar_ends = '||'			% the characters to use as stoppers for the bar
		max_extra_length = 0	% the number of allowed extra characters
	end
	
	properties (Access=private)
		storagefile				% the location of the file where the progress is stored
	end
	
	properties (Dependent,Access=private)
		printstr				% the thing to put in fprintf
	end
	
	methods
		function self = TextParallelProgressBar(steps, max_extra_length)
			% the constructor
			if nargin >= 2
				self.max_extra_length = max_extra_length;
			end
			self.steps = steps;
			self.storagefile = tempname;
		end
		function val = get.printstr(self)
			val = ['%' num2str(ceil(log10(self.steps))+1) 'd'];
		end
		function initialize(self)
			% draws the progress bar at 0%; this is necessary because we
			% need to draw it at least once without erasing previous
			% characters. also creates the file to write to.
			if self.max_extra_length == 0
				extrastr = '';
			else
				extrastr = ' '*ones(1,self.max_extra_length);
			end
			fprintf([self.barstring(0) '%s%s\n'], '%',extrastr);
			drawnow;
			
			% make/remake the file  storing the progress. we opt to store
			% info an # of lines because this will minimize the amount of
			% time the function is open for writing, which reduces the risk
			% of two branches trying to write at the same time
			fid = fopen(self.storagefile,'w+');
			fclose(fid);
		end
		function display(self, extrastr)
			% Draws the progress bar, and erases the old one
			%	- fraction:	A number between 0 and 1
			%	- params: (optional; default char(10)) An extra string to
			%				append to. It will be chopped of after
			%				max_extra_length characters. Your string should
			%				not contain escape strings, or else its length
			%				will be miscalculated.
			if self.max_extra_length == 0 || nargin < 2
				extrastr = '';
			else
				extrastr = extrastr(1:min(end,self.max_extra_length));
			end
			
			% open the file, print a new line
			fid = fopen(self.storagefile,'a');
			fprintf(fid,'1\n');
			fclose(fid);
			
			% open the file, count the lines
			fid = fopen(self.storagefile,'r');
			step = length(fscanf(fid, '%d'));
			fclose(fid);
			
			% fraction of completion
			fraction = min(1,step/self.steps);
			
			extrastr = [extrastr ' '*ones(1,self.max_extra_length-length(extrastr))];
			fraction = min(max(real(fraction),0),1);
			bar = self.barstring(fraction);
			erase = ['' char(8)*ones(1,length(bar)+length(extrastr)+2)];
			fprintf([erase bar '%s' extrastr '\n'], '%');
			drawnow;
		end
		function delete(self)
			% delete the temporary file
			delete(self.storagefile);
		end
	end
	
	methods (Access=private)
		function bar = barstring(self,fraction)
			% prints the bar and the percent done, except the percent sign
			done = round(self.width*fraction);
			done_str = self.done_char*ones(1, done);
			notdone_str = self.notdone_char*ones(1, self.width-done);
			bar = sprintf([self.bar_ends done_str notdone_str self.bar_ends '%3d'],round(fraction*100));
		end
	end
	
end