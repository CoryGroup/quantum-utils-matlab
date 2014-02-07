classdef ProgressBar
% Abstract class for a progress bar
	
	methods (Abstract)
		initialize(self);
		% Performs any necessary actions before the display function is
		% called
		display(self,varargin);
		% displays/updates the progress bar
	end
	
end