function [best_sol, best_fit, convergence_curve] = SCA(SearchAgents_no, Max_iteration, lb, ub, dim, fobj)
% SCA - Sine Cosine Algorithm implementation (robust, English)
%
% USAGE:
%   [best_sol, best_fit, convergence_curve] = SCA(N, Max_iter, lb, ub, dim, fobj)
%
% Inputs:
%   SearchAgents_no - population size (N)
%   Max_iteration   - maximum number of iterations
%   lb, ub          - lower and upper bounds (either scalars or 1xd vectors)
%   dim             - problem dimension
%   fobj            - handle to objective function fobj(x) (x is a row vector)
%
% Outputs:
%   best_sol        - best solution vector found (1 x dim)
%   best_fit        - best fitness value (scalar)
%   convergence_curve - 1 x Max_iteration array of best fitness per iteration

    % initialize population
    X = initialization(SearchAgents_no, dim, ub, lb);

    best_sol = zeros(1, dim);
    best_fit = inf;

    convergence_curve = nan(1, Max_iteration);
    Objective_values = nan(1, size(X,1));

    % evaluate initial population and find the best
    for i = 1:size(X,1)
        val = fobj(X(i,:));
        if ~isfinite(val)
            % if objective returns NaN/Inf, treat as very bad
            val = inf;
        end
        Objective_values(i) = val;

        if val < best_fit
            best_fit = val;
            best_sol = X(i,:);
        end
    end

    % store initial best
    convergence_curve(1) = best_fit;

    % main loop
    t = 2;
    a = 2; % parameter 'a' (controls r1)
    while t <= Max_iteration

        % r1 decreases linearly from 'a' to 0
        r1 = a - t * (a / Max_iteration);

        % update positions
        for i = 1:size(X,1)
            for j = 1:dim
                r2 = 2 * pi * rand();   % random angle
                r3 = 2 * rand();        % random scale
                r4 = rand();            % random switch

                if r4 < 0.5
                    X(i,j) = X(i,j) + r1 * sin(r2) * abs(r3 * best_sol(j) - X(i,j));
                else
                    X(i,j) = X(i,j) + r1 * cos(r2) * abs(r3 * best_sol(j) - X(i,j));
                end
            end
        end

        % boundary control and evaluation
        for i = 1:size(X,1)
            % If lb/ub are vectors or scalars the comparisons still work in MATLAB
            Flag4ub = X(i,:) > ub;
            Flag4lb = X(i,:) < lb;
            X(i,:) = (X(i,:) .* (~(Flag4ub + Flag4lb))) + ub .* Flag4ub + lb .* Flag4lb;

            val = fobj(X(i,:));
            if ~isfinite(val)
                val = inf;
            end
            Objective_values(i) = val;

            % update best if found
            if val < best_fit
                best_fit = val;
                best_sol = X(i,:);
            end
        end

        convergence_curve(t) = best_fit;

        % increase iteration
        t = t + 1;
    end

    % If for some reason best_fit remained inf, make sure outputs are consistent
    if ~isfinite(best_fit)
        best_fit = NaN;
    end
    if all(best_sol == 0) && isnan(best_fit)
        % no valid solution found
        best_sol = nan(1, dim);
    end
end

% -------------------------------------------------------------------------
% Initialization helper (local function)
% -------------------------------------------------------------------------
function X = initialization(SearchAgents_no, dim, ub, lb)
% Returns SearchAgents_no-by-dim matrix with entries in [lb(i), ub(i)].
% ub and lb can be scalars or 1xd vectors.

    if isscalar(ub) && isscalar(lb)
        % same bound for all variables
        X = rand(SearchAgents_no, dim) .* (ub - lb) + lb;
        return;
    end

    % if ub/lb are vectors, ensure they are row vectors
    ub = ub(:)'; lb = lb(:)';
    if numel(ub) ~= dim || numel(lb) ~= dim
        error('Dimensions of ub/lb do not match dim.');
    end

    X = zeros(SearchAgents_no, dim);
    for j = 1:dim
        ubj = ub(j);
        lbj = lb(j);
        X(:, j) = rand(SearchAgents_no, 1) .* (ubj - lbj) + lbj;
    end
end
