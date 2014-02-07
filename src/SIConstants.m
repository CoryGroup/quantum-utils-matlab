classdef SIConstants
    % Various constants of nature in SI units (add more in as you need them)

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
		h		= 6.62606957e-34		% Planck's constant
		hbar	= 1.054571726e-34		% Planck's reduced constant
		c		= 299792458				% Speed of light
		e		= 1.602176565e-19		% Elementary charge
		me		= 9.10938291e-31		% Mass of an electron
		mp		= 1.672621777e-27		% Mass of a proton
		mn		= 1.674927351e-27		% Mass of a neutron
		G		= 6.67384e-11			% Gravitational constant			
		alpha	= 7.2973525698e-3		% Fine structure constant
		ge		= 2.0023193043617		% Gyromagnetic ratio of an electron
		muB		= 9.27400915e-24		% Bohr magneton
	end

end
