function install()
    % install   Adds QuantumUtils to the default MATLAB path.
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


    % Try the naive thing.
    addpath([pwd filesep 'src']);
    err = savepath;
    
    unixlike = isunix || ismac;

    % If we errored out, we must fix it in an OS dependent way.
    if err
        if unixlike
            
            % To fix the most likely problem under UNIX-like OSes, we must
            % change the permissions for pathdef.m. Hence, we start by locating
            % the file.
            pathdefat = which('pathdef');

            % Next, we discover the current permissions.
            [status, oldperms] = system(['stat -c %a ' pathdefat]);
            % Trim the newline that MATLAB appends to the results of
            % system.
            oldperms = strtrim(oldperms);
            
            % Inform the user as to what we're doing.
            disp('To proceed with the installation, we need root permissions.');
            
            % Now we sudo and change to mode 777.
            suchmod(pathdefat, '777');

            % We try to save the path again.
            err = savepath;
            
            % Finally, we revert to the old file permissions.
            suchmod(pathdefat, oldperms);
            
            % Check the new value of err and see if it worked.
            if err
                error('savepath seems to have failed even with corrected permissions.');
            end
            
		else
            warning('Correcting permissions for pathdef.m under Windows is not currently supported. QuantumUtils must be manually installed.');
        end
	end
	
	if ~err
		fprintf('It appears that quantum-utils has been successfully installed.\n');
	end
    
end

function suchmod(file, mode)
    % suchmod   Changes the permissions of a file on a UNIX-like OS using
    %           sudo.
    
    system(['sudo chmod ' mode ' ' file]);

end
