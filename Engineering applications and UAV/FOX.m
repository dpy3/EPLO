function [Best_pos, Best_score_history, curve] = FOX(SearchAgents_no, Max_iter, lb, ub, dim, fobj)
% FOX  - Robust implementation of the FOX optimizer (minimization).
%
% USAGE:
%   [Best_pos, Best_score_history, curve] = FOX(SearchAgents_no, Max_iter, lb, ub, dim, fobj)
%
% - Returns Best_pos (1 x dim): best solution vector found
% - Returns Best_score_history (1 x Max_iter): best fitness at each iteration
% - Returns curve (same as Best_score_history)
%
% Notes:
% - This implementation is defensive: it protects against divide-by-zero,
%   invalid objective function calls, NaN/Inf values, scalar/vector lb/ub, etc.
% - fobj is called as fobj(x) where x is a row vector of length dim.
% - It is set up for minimization (Best_score starts at +Inf).

    % --- Defensive checks for bounds ---
    if isscalar(lb)
        lb_vec = lb * ones(1, dim);
    else
        lb_vec = lb(:)'; % ensure row
        if numel(lb_vec) ~= dim
            error('FOX: lb length (%d) does not match dim (%d).', numel(lb_vec), dim);
        end
    end

    if isscalar(ub)
        ub_vec = ub * ones(1, dim);
    else
        ub_vec = ub(:)'; % ensure row
        if numel(ub_vec) ~= dim
            error('FOX: ub length (%d) does not match dim (%d).', numel(ub_vec), dim);
        end
    end

    % Make sure lb <= ub elementwise
    if any(lb_vec > ub_vec)
        error('FOX: some lower-bounds are greater than upper-bounds.');
    end

    % Initialize outputs & internal state
    Best_pos = zeros(1, dim);
    Best_score = inf;               % Minimization
    MinT = realmax;                 % start with large finite MinT (avoid Inf)
    curve = nan(1, Max_iter);
    Best_score_history = nan(1, Max_iter);

    % Initialize population
    X = initialization(SearchAgents_no, dim, ub_vec, lb_vec);

    % Ensure X numeric and finite
    X(~isfinite(X)) = repmat((lb_vec + ub_vec)/2, sum(~isfinite(X(:))), 1);

    % algorithm parameters
    c1 = 0.18;
    c2 = 0.82;

    % Main loop
    for iter = 1:Max_iter
        % Evaluate all agents
        for i = 1:SearchAgents_no
            % enforce bounds (element-wise)
            X(i, :) = max(min(X(i, :), ub_vec), lb_vec);

            % Call objective safely
            try
                % ensure we pass a row vector
                xi = double(X(i, :));
                if size(xi,1) > 1, xi = xi(:)'; end
                fitness = fobj(xi);
                % sometimes fobj returns vector -> take scalar if so
                if numel(fitness) > 1
                    fitness = fitness(end);
                end
                if ~isfinite(fitness)
                    % treat non-finite as large penalty
                    fitness = realmax/10;
                end
            catch ME
                % If user objective throws, record warning and assign large penalty
                warning('FOX: objective function failed for agent %d at iter %d: %s', i, iter, ME.message);
                fitness = realmax/10;
            end

            % Update global best
            if fitness < Best_score
                Best_score = fitness;
                Best_pos = X(i, :);
            end
        end

        % Save current best for this iteration
        curve(iter) = Best_score;
        Best_score_history(iter) = Best_score;

        % Exploration/exploitation movement
        a = 2 * (1 - (iter / Max_iter));  % decreasing factor
        for i = 1:SearchAgents_no
            r = rand;
            p = rand;

            if r >= 0.5
                % Use small non-zero Time to avoid division by zero
                Time = rand(1, dim) + eps;   % elementwise
                % sps = Best_pos ./ Time  (element-wise safe)
                sps = Best_pos ./ Time;
                Distance_S_Travel = sps .* Time;
                Distance_Fox_Rat = 0.5 .* Distance_S_Travel;

                tt = sum(Time) / dim;
                t = tt / 2;
                Jump = 0.5 * 9.81 * t^2;

                if p > c1
                    X(i, :) = Distance_Fox_Rat .* (Jump * c1);
                else
                    X(i, :) = Distance_Fox_Rat .* (Jump * c2);
                end

                % Keep track of the smallest observed Time-like metric
                if tt < MinT
                    MinT = tt;
                end
            else
                % Random walk / exploration: use bounded Gaussian step
                % Use a finite MinT fallback if MinT is still huge
                if ~isfinite(MinT) || MinT <= 0 || MinT > 1e6
                    minT_use = 1.0;
                else
                    minT_use = MinT;
                end
                step = randn(1, dim) .* (minT_use * a);
                X(i, :) = Best_pos + step;
            end

            % After update, clip to bounds to keep feasible
            X(i, :) = max(min(X(i, :), ub_vec), lb_vec);

            % Replace any NaN/Inf with random feasible value
            bad = ~isfinite(X(i, :));
            if any(bad)
                X(i, bad) = lb_vec(bad) + rand(1, sum(bad)) .* (ub_vec(bad) - lb_vec(bad));
            end
        end

        % end iteration
    end

    % Final outputs:
    % Best_pos is 1 x dim
    % Best_score_history is 1 x Max_iter
    % curve identical
    % Make sure outputs are proper shape
    Best_pos = double(Best_pos(:)');                 % row
    Best_score_history = double(Best_score_history); % row
    curve = double(curve);

end

% --------------------------
% initialization helper
% --------------------------
function X = initialization(SearchAgents_no, dim, ub, lb)
    % ub and lb are row vectors of length dim
    if isscalar(ub)
        ub = ub * ones(1, dim);
    end
    if isscalar(lb)
        lb = lb * ones(1, dim);
    end
    X = rand(SearchAgents_no, dim) .* (ub - lb) + lb;
    % fix any numerical issues
    X(~isfinite(X)) = nan;
    nanrows = any(isnan(X), 2);
    for r = find(nanrows)'
        X(r, :) = lb + rand(1, dim) .* (ub - lb);
    end
end
