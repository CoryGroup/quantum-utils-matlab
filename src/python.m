function [varargout] = python( varargin )
    % python - Wrapper to call the Python interpreter from within MATLAB.
    % 
    % [status, result] = python(args) - Calls the system command "python"
    %     with the given arguments, returning the status code and result
    %     to 'status' and 'result', respectively. For more details, see
    %     "help system".
    %
    % Notes:
    %     Only works on UNIX-like hosts right now.
    %
    % Example:
    %     >> python foobar.py
    
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


    args = '';
    
    % Get the default python interpreter and strip newlines from the
    % output.
    [~, which_p] = system('which python');
    which_p = char(java.lang.String(which_p).replaceAll(sprintf('\n'), ''));
    
    python_bin   = getpref('quantumutils', 'python_bin',  which_p);
    python_path  = getpref('quantumutils', 'python_path', '');
    
    if ~isempty(python_path) && ~isempty(getenv('PYTHONPATH'))
        python_path = [':' python_path]
    end
    
    base_cmd = sprintf('LD_LIBRARY_PATH= PYTHONPATH=%s %s', [getenv('PYTHONPATH') python_path], python_bin);
    
    if nargin == 0
        eval(sprintf('!%s', base_cmd));
        status = 0;
        result = [];
    else

        for idx_arg = 1:length(varargin)
            args = [args ' ' varargin{idx_arg}];
        end

        if nargin > 0
            args = args(2:end);
        end

        %[status, result] = system([base_cmd args]);
        eval(['!' base_cmd ' ' args]);
       
        % FIXME!!
        status = 0;
        result = '';
        
    end
    
    if nargout == 1
        varargout{1} = status;
    elseif nargout == 2
        varargout{1} = status;
        varargout{2} = result;
    end

end

