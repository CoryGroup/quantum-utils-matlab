function y = iif(cond, iftrue, iffalse)
    % iif   Returns values based on a conditional test.
    %
    % iif(cond, iftrue, iffalse) returns iftrue if cond == 1 and returns
    % iffalse otherwise.
    %
    % This function is rather trivial, but has the nice effect of turning
    % if statements into expressions, a la the ternary if operator common to
    % many other languages (often written ?:).
    %
    % The main purpose of this function is to support automated code conversion
    % from languages that have ternary if operators.

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

    
    if cond
        y = iftrue;
    else
        y = iffalse;
    end
    
end
