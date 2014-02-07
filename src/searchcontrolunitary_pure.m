function [U H costval] = searchcontrolunitary_pure(control_algebra, states_in, states_out, method)
    % Given a control algebra, this function searches for a unitary which takes
    % a given set of input states to a given set of ouput states.
    %
    % Inputs:
    % 	- control_algebra:	A basis.Basis instance spanning the control lie
    %						algebra
    % 	- states_in:		A maxtrix whose columns are the input pure states
    %   - states_out:		A matrix whose columns are pure states which are
    %						the desired outputs of the input states under some
    %						unitary that we are searching for
    %   - method:			Chooses the optimization routine to be used:
    %						-> 'simplex', the fminsearch simplex method 
    %						-> 'ga', the ga genetic algorithm 
    %						-> 'patternsearch', the patternsearch algorithm
    %						-> 'gradient', the standard fmincon algorithm
    % 
    % Outputs:
    %	- U:				A unitary in the lie group generated by
    %						control_algebra, and if you have enough control,
    %						and if the optimazation is successful, it will be
    %						such that U*state_in_k = state_out_k for all
    %						columns states_in_k and states_out_k of states_in
    %						and states_out U is such that U = expm(H)
    %	- H:				The Hamiltonian which generated U
    %	- costval:			The final value of the cost function
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


	% define matrix size and dimension of control algebra
	h = control_algebra.size(1);
    s = size(states_in, 2);
	dim = control_algebra.dimension;
	B = control_algebra.standardform;
    
    % check that necessary conditions are met
    if size(states_in, 2) ~= size(states_out,2)
        error('There must be as many input states as output states');
    end
    if size(states_in, 1) ~= h || size(states_out, 1) ~= h
        error('Dimension mismatch between the algebra and the input or output states');
    end
    if hsnorm(states_in'*states_in - eye(size(states_in,2))) > 1e-8
        error('Your input states are not orthonormal');
    end
    if hsnorm(states_out'*states_out - eye(size(states_out,2))) > 1e-8
        error('Your output states are not orthonormal');
    end
    
    % print some info
    fprintf('--------------------------------------------------------\n');
    fprintf('There are %d control directions to search over.\n', dim);
    fprintf('Searching for a unitary which at minimum maps as follows:\n');
    for k = 1:size(states_in,2)
   %     fprintf('%s |--> %s\n', printpurestate(states_in(:,k), 0), printpurestate(states_out(:,k), 0));
    end
    fprintf('--------------------------------------------------------\n');
    
	% the idea is to a minimization search through the control algebra for
	% a skew-hermitian hamiltonian (SHH) which minimizes the sum of the
	% fidelities for each of the input and output states instead of storing
	% the entire SHH, we take advantage of the fact that the control
	% algebra's dimension is probably less than the full dimension of
	% operator space, and hence we store only the coefficients for a basis
	% of of the algbra, namely, the basis provided as columns of the matrix
	% "control_algebra"

	% the following inline function just converts the coefficient format
	% into SSH format
	convert = @(x) control_algebra.createFromCoeffs(x);

	% the cost function does the following fidelity:
	% min_k(|<out_k|expm(x)|in_k>|)
    % it is written out at the bottom of this file; the following is just a
    % handle
	cost = @(x) ccost(x, states_in, states_out, control_algebra.standardform, h, s, dim);
	
	% use one of the following optimization routines to do the hard work
    % You may want to use specific initial conditions; those can be
    % specified below
    tic;
    switch method
        case 'simplex'
            x0 = 2*rand(1,dim)-ones(1,dim);
            options = optimset('MaxFunEvals', 100000, 'PlotFcns', @optimplotx);
            [x, costval] = fminsearch(cost, x0, options);
        case 'ga'
            options = gaoptimset('Display', 'iter', ...
                                 'UseParallel', 'always', ...
                                 'TolFun', 1e-6, ...
                                 'Generations', 100000);
            [x, costval] = ga(cost, dim, options);
        case 'patternsearch'
            x0 = 2*rand(1,dim)-ones(1,dim);
            options = psoptimset('Display', 'iter', ...
                                 'UseParallel', 'always');
            [x, costval] = patternsearch(cost, x0,[],[],[],[],[],[],[],options);
            fprintf('Search finished with fidelity of %2.6f\n', -1*costval);
        case 'gradient'
            x0 = zeros(1,dim);
            x0 = 2*rand(1,dim)-ones(1,dim);
            options = optimset('Display', 'iter', ...
                               'UseParallel', 'always', ...
                               'TolX', 1e-10, ...
                               'TolFun', 1e-10, ...
                               'MaxFunEvals', 1e6);
            [x, costval] = fmincon(cost, x0, [], [], [], [], -1000*ones(1,dim), 1000*ones(1,dim), [], options);
            fprintf('Search finished with fidelity of %2.6f\n', -1*costval);
        otherwise
            error('Your optimization method did not match any of those available to this function');
    end
    T = toc;
    fprintf('The optimization took %s\n', datestr(datenum(0,0,0,0,0,T),'HH:MM:SS'));

	% now prepare the output
	H = convert(x);
	U = expm(H);

end

function [c g] = ccost(x, states_in, states_out, control_algebra, h, s, dim)
    % A is the current point in skew-Hermitian space
    A = reshape(sum(repmat(x,h^2,1).*control_algebra,2),h,h);
    % States_evolve is the intial states evolved under A
    states_evolve = expm(A)*states_in;
    
    % compute the (non-abs'd) fidelities; save abs'ing them and summing
    % them until after we've used this matrix for the derivative
    c = -1*sum(abs(sum(conj(states_out).*(states_evolve))))/s;
end

% The following function includes a gradient, but it seems that
% approximating it is much better
function [c g] = cccost(x, states_in, states_out, control_algebra, h, s, dim)
    % A is the current point in skew-Hermitian space
    A = reshape(sum(repmat(x,h^2,1).*control_algebra,2),h,h);
    % States_evolve is the intial states evolved under A
    states_evolve = expm(A)*states_in;
    
    % compute the (non-abs'd) fidelities; save abs'ing them and summing
    % them until after we've used this matrix for the derivative
    c = sum(conj(states_out).*(states_evolve));
    
    % the following mess computes the gradient. good luck.
    B = reshape(control_algebra, h, h*dim);
    g = states_out'*(B - 0.5*(A*B - reshape((A.'*reshape(B.', h, h*dim)).', h, h*dim)));
    g = reshape(g, s*dim, h).';
    g = reshape(sum(repmat(states_evolve, 1, dim).*g), dim, s);
    g = 2*real(sum(g.*repmat(c, dim, 1), 2).');
    
    % sum up the fidelities
    c = -1*sum(abs(c).^2);
end
