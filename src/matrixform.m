function mat = matrixform(maphandle, domain, image)
    % Turns a linear map (presented as a function handle -- it is the user's
    % responsibility to ensure that the map is linear) into a matrix with
    % respect to the bases domain and range.
    %
    % Arguments:
    %	- maphandle:	A function handle to a linear map. The function must
    %				accept a single array as input, and output a single array.
    %	- domain:	Either an istance of the Basis class which spans the domain
    %				of the linear map OR a 1D array of positive integers which
    %				specify the size of array handle expects as input.
    %	- range:    Either an istance of the Basis class which spans the range
    %				of the linear map OR a 1D array of positive integers which
    %				specify the size of array which maphandle outputs
    %
    % Outputs:
    %	- mat:		The matrix of the linear map with respect to the given
    %				basis. If 1D arrays were given instead of Basis instances,
    %				the column stacking convention is assumed. To be explicit,
    %				the following documents the outcomes of the four possible 
    %				cases:
    %				CASE 1: domain and image are both Basis instances
    %					- maphandle(X) == unvec(mat*vec(X,domain),image) for all X
    %				CASE 2: domain and image are both 1D arrays of integers
    %					- maphandle(X) == unvec(mat*vec(X,'col'),'col',image) for all X
    %				CASE 3: domain is a Basis instance and image is a 1D array of integers
    %					- maphandle(X) == unvec(mat*vec(X,domain),'col',image) for all X
    %				CASE 4: image is a Basis instance and domain is a 1D array of integers
    %					- maphandle(X) == unvec(mat*vec(X,'col'),image) for all X
    %
    % Usage Example:
    % 	% first, make a linear map and two bases
    % 	map = @(X) comm(X, Pauli.Z);
    % 	d = [2 2];
    % 	B1 = basis.PauliONBasis(1);
    % 	B2 = basis.MatrixLRBasis(2, 2);
    % 
    % 	% Now generate something random to test with
    % 	R = irand(2);
    % 
    % 	% Now well test to make sure our matrix does what its supposed to, in
    % 	% each of the four cases (each test should return 0):
    % 	% CASE 1:
    % 	A = matrixForm(map, B1, B2);
    % 	R = irand(2);
    % 	pnorm(map(R) - unvec(A*vec(R,B1),B2))
    % 
    % 	% CASE 2:
    % 	A = matrixForm(map, d, d);
    % 	R = irand(2);
    % 	pnorm(map(R) - unvec(A*vec(R)))
    % 
    % 	% CASE 3:
    % 	A = matrixForm(map, B1, d);
    % 	R = irand(2);
    % 	pnorm(map(R) - unvec(A*vec(R,B1)))
    % 
    % 	% CASE 4:
    % 	A = matrixForm(map, d, B2);
    % 	R = irand(2);
    % 	pnorm(map(R) - unvec(A*vec(R),B2))
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


% if the domain or image are a single integer, append a 1 to appease the
% reshape function
if issizelike(domain) && length(domain) == 1
	domain = [domain 1];
end
if issizelike(image) && length(image) == 1
	domain = [image 1];
end

if issizelike(domain) && issizelike(image)
	% we have two columnization requests
	% get size of output matrix
	R = prod(image);
	C = prod(domain);
	% initialize
	mat = zeros(R, C);
	v = zeros(C, 1);
	% loop through and compute each column
	for k = 1:C
		if k > 1, v(k-1) = 0; end
		v(k) = 1;
		mat(:,k) = vec(maphandle(unvec(v,'col',domain)),'col');	
	end
elseif issizelike(domain) && isa(image, 'basis.Basis')
	% we have one columnization requst, and one Basis instance
	% get size of output matrix
	R = image.dimension;
	C = prod(domain);
	% initialize
	mat = zeros(R, C);
	v = zeros(C, 1);
	% loop through and compute each column
	for k = 1:C
		if k > 1, v(k-1) = 0; end
		v(k) = 1;
		mat(:,k) = vec(maphandle(unvec(v,'col',domain)),image);	
	end
elseif issizelike(image) && isa(domain, 'basis.Basis')
	% we have one columnization requst, and one Basis instance
	% get size of output matrix
	R = prod(image);
	C = domain.dimension;
	% initialize
	mat = zeros(R, C);
	v = zeros(C, 1);
	% loop through and compute each column
	for k = 1:C
		if k > 1, v(k-1) = 0; end
		v(k) = 1;
		mat(:,k) = vec(maphandle(unvec(v,domain)),'col');	
	end
elseif isa(domain, 'basis.Basis') && isa(image, 'basis.Basis')
	% two basis instances were given
	% get size of output matrix
	R = image.dimension;
	C = domain.dimension;
	% initialize
	mat = zeros(R, C);
	v = zeros(C, 1);
	% loop through and compute each column
	for k = 1:C
		if k > 1, v(k-1) = 0; end
		v(k) = 1;
		mat(:,k) = vec(maphandle(unvec(v,domain)),image);	
	end
else
	error(['Unexpected basis input. domain and image must be 1D arrays' ...
			'of positive integers, or an instance of the basis class.']);
end

end
