function h = plotspectrum(H, s, plot_title, plot_xlabel, plot_ylabel)
    % Plots the eigenvalues of a Hamiltonian as a function of time
    %
    % Arguments:
    %	- H:		A function handle with one input parameter which returns a
    %				Hermitian matrix, i.e., a time dependent Hamiltonian.
    %	- s:		A 1D array of times at which to find the eigenvalues of H
    %				and	plot them
    %	- title:	(optional; default 'Energy Structure') A string to put as 
    %				the title of the plot
    %	- xlabel:	(optional; default 'Time') A string to put as the x axis
    %				label
    %	- ylabel:	(optional; default 'Energy') A string to put as the y axis
    %				label
    %
    % Usage Example:
    %
    % % Make a Hamiltonian:
    % w1 = @(t) exp(-(t-1).^2);
    % H = @(t) Pauli.Z + w1(t)*Pauli.X;
    % 
    % % Now plot the eigenvalues
    % plotspectrum(H, 0:0.05:3, 'Simple Example');
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


	if nargin < 3,	plot_title = 'Energy Structure'; end
	if nargin < 4,	plot_xlabel = 'Time'; end
	if nargin < 5,	plot_ylabel = 'Energy'; end

	if ~isa(H, 'function_handle') || nargin(H) ~= 1
		error('"H" is expected to be a function handle with one input');
	end
	if ~isnumeric(s) || numel(s) ~= length(s)
		error('"s" is expected to be a 1D array of numbers');
	end

	% calculate all of the eigenvalues.
	eigenvalues = cell2mat(arrayfun(@(s) eig(H(s)), s, 'UniformOutput', false));

	% make the plots
	h = plot(s, eigenvalues);
	title(plot_title);
	xlabel(plot_xlabel);
	ylabel(plot_ylabel);
	axis([0 max(s) 1.1*[min(min(eigenvalues)) max(max(eigenvalues))]]);
	
end
