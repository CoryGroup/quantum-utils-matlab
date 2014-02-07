function usecvx(endpoint)
    % This function helps smooth out the integration of the quantum-utils
    % matlab package and the convex programming package CVX, which
    % quantum-utils uses. Both packages have the need to name their functions
    % certain things, and some of these names overlap, like vec. So this
    % function should be used on either side of a cvx program, and all it does
    % is switch the current path to the cvx folder, and then switch it back
    % when the convex program is done, so that during the convex program, CVX's
    % functions take precedence over quantum-util's functions. To ensure that
    % quantum util's functions take precedence otherwise, it should be at the
    % top of pathdef.m file. Calling this function with the input argument
    % 'postcvxinstall' will move it there.
    %
    % Arguments:
    %	- endpoint:     One of three values: 'begin', called just before a cvx
    %                   program; 'end', called just after a cvx program; and
    %                   'postcvxinstall', called after you have installed cvx
    %
    %
    % Usage Example:
    %		
    %	See dnorm.m code for an example
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


    %global oldpath_forcvx;

    if strcmp(endpoint, 'begin')
        % save the current path, and change it to the cvx 
		quantumutilsdir = fileparts(which('navtoquantutils'));
		addpath(quantumutilsdir, '-end');
        %oldpath_forcvx = pwd;
        %cvxpath = fileparts(which('cvx_setup'));
        %cd(cvxpath);
    elseif strcmp(endpoint, 'end')
        % restore the path from where it was
		quantumutilsdir = fileparts(which('dnorm'));
		addpath(quantumutilsdir, '-begin');
        %cd(oldpath_forcvx);
        %clear oldpath_forcvx;
    elseif strcmp(endpoint, 'postcvxinstall')
        % this will move quantum-utils to the top of the path list, thus
        % making its functions take precedence
        out = input('About to attempt to move quantum-utils to the top of your path list. \nIf you have used the addpath command _this session_, those paths will, \nas a side effect, be added to the permanent path list too. \nDo you wish to proceed? (Y/n)', 's');
        if isempty(out)
            out = 'Y';
        end
        out = lower(out);
        if out(1) ~= 'y'
            error('Attempt to move quantum-utils to the top of your path aborted.');
        end
        
        quantumutilspath = fileparts(which('usecvx'));
        addpath(quantumutilspath);
        err = savepath;
        unixlike = isunix || ismac;
        % If we errored out, we must fix it in an OS dependent way.
        if err
            if unixlike

                % To fix the most likely problem under UNIX-like OSes, we
                % must change the permissions for pathdef.m. Hence, we
                % start by locating the file.
                pathdefat = which('pathdef');

                % Next, we discover the current permissions.
                [~, oldperms] = system(['stat -c %a ' pathdefat]);
                % Trim the newline that MATLAB appends to the results of
                % system.
                oldperms = strtrim(oldperms);

                % Inform the user as to what we're doing.
                disp('To proceed with modifying your path file, we need root permissions.');

                % Now we sudo and change to mode 777.
                suchmod(pathdefat, '777');

                % We try to save the path again.
                err = savepath;

                % Finally, we revert to the old file permissions.
                suchmod(pathdefat, oldperms);

                % Check the new value of err and see if it worked.
                if err
                    warning('Savepath seems to have failed even with corrected permissions.');
                else
                    disp('Operation successful.');
                end

            else

                warning('Correcting permissions for pathdef.m under Windows is not currently supported.');

            end
        end
    end

end

function suchmod(file, mode)
    % suchmod   Changes the permissions of a file on a UNIX-like OS using
    %           sudo.
    
    system(['sudo chmod ' mode ' ' file]);

end
