function checkcvx()
    % Determines whether or not the convex programming package CVX is installed
    % or not. If you do not have it, it can be found at http://cvxr.com/cvx/
    %
    % Arguments:
    %
    % Outputs:
    %	- ans:	1 if CVX is installed, 0 otherwise
    %
    % Usage Example:
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


% cross our fingers that nothing else on the path contains the string
% '\cvx' or '/cvx'. this could probably use a more robust implementation in
% the future
if isempty(regexp(path, '[/\\]cvx', 'once'))
	error(['The current operation predicts that it will require ' ...
		   'the convex programming package CVX, which is not ' ...
		   'currently on your path. If you dont have this package, it ' ...
		   'can be downloaded at http://cvxr.com/cvx/. See their ' ...
		   'instructions for how to install.']);
end

end
