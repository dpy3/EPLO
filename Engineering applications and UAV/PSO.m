function [best_solution, best_fit_history, conv_curve] = PSO(N, MaxIter, lb, ub, dim, fobj)
% PSO - robust Particle Swarm Optimization compatible with run_type9
% Usage: [best_sol, best_fit_hist, conv_curve] = PSO(N, MaxIter, lb, ub, dim, fobj)
%
% Inputs:
%   N       - population size
%   MaxIter - number of iterations
%   lb, ub  - scalar or 1-by-dim vectors (bounds)
%   dim     - problem dimension
%   fobj    - function handle: fitness = fobj(x) where x is 1-by-dim
%
% Outputs:
%   best_solution      - 1-by-dim best position found
%   best_fit_history   - 1-by-MaxIter best fitness per iteration
%   conv_curve         - alias for best_fit_history

    %% Input normalization & checks
    if iscolumn(lb), lb = lb'; end
    if iscolumn(ub), ub = ub'; end
    if isscalar(lb), lb = repmat(lb,1,dim); end
    if isscalar(ub), ub = repmat(ub,1,dim); end
    lb = reshape(lb,1,dim);
    ub = reshape(ub,1,dim);
    if any(lb > ub)
        error('PSO:Bounds','Each element of lb must be <= corresponding element of ub.');
    end
    if N < 1 || MaxIter < 1
        error('PSO:Params','N and MaxIter must be positive integers.');
    end

    %% Parameters (tunable)
    w_max = 0.9;        % inertia weight max
    w_min = 0.4;        % inertia weight min
    c1 = 2.0;           % cognitive coefficient
    c2 = 2.0;           % social coefficient
    vmax_ratio = 0.2;   % velocity clamping as ratio of (ub-lb)

    %% Initialization
    % positions and velocities
    span = (ub - lb);
    positions = repmat(lb, N, 1) + rand(N, dim) .* repmat(span, N, 1);
    velocities = zeros(N, dim);

    % evaluate initial fitness robustly
    personal_best_positions = positions;
    personal_best_scores = inf(N,1);
    for i = 1:N
        personal_best_scores(i) = safe_eval(fobj, positions(i,:));
    end

    % global best
    [Best_score, best_idx] = min(personal_best_scores);
    if isempty(best_idx) || isnan(Best_score)
        % fallback: set worst-case
        Best_score = inf;
        Best_pos = positions(1,:);
    else
        Best_pos = positions(best_idx, :);
    end

    % Preallocate convergence history
    Convergence_curve = inf(1, MaxIter);

    % velocity limits
    vmax = vmax_ratio * span;           % 1-by-dim
    vmax_mat = repmat(vmax, N, 1);      % N x dim

    %% Main PSO loop
    for iter = 1:MaxIter
        % dynamic inertia
        if MaxIter == 1
            w = w_min;
        else
            w = w_max - (w_max - w_min) * ( (iter-1) / (MaxIter-1) );
        end

        for i = 1:N
            % update velocity
            r1 = rand(1, dim);
            r2 = rand(1, dim);
            cognitive = c1 .* r1 .* (personal_best_positions(i,:) - positions(i,:));
            social = c2 .* r2 .* (Best_pos - positions(i,:));
            velocities(i,:) = w .* velocities(i,:) + cognitive + social;

            % clamp velocity
            velocities(i,:) = max(min(velocities(i,:), vmax_mat(i,:)), -vmax_mat(i,:));

            % update position
            positions(i,:) = positions(i,:) + velocities(i,:);

            % boundary handling (reflective)
            % if outside, set to bound and reverse velocity component
            outside_low = positions(i,:) < lb;
            outside_high = positions(i,:) > ub;
            if any(outside_low)
                positions(i, outside_low) = lb(outside_low);
                velocities(i, outside_low) = -0.5 * velocities(i, outside_low);
            end
            if any(outside_high)
                positions(i, outside_high) = ub(outside_high);
                velocities(i, outside_high) = -0.5 * velocities(i, outside_high);
            end

            % evaluate fitness robustly
            fitness = safe_eval(fobj, positions(i,:));

            % update personal best
            if fitness < personal_best_scores(i)
                personal_best_scores(i) = fitness;
                personal_best_positions(i,:) = positions(i,:);
            end

            % update global best
            if fitness < Best_score
                Best_score = fitness;
                Best_pos = positions(i,:);
            end
        end

        % record convergence (ensure finite numeric)
        if isempty(Best_score) || isnan(Best_score) || isinf(Best_score)
            Convergence_curve(iter) = inf;
        else
            Convergence_curve(iter) = Best_score;
        end

        % optional early termination: if desired threshold reached (commented)
        % if Best_score <= target_threshold, break; end
    end

    %% Prepare outputs
    best_solution = reshape(Best_pos, 1, dim);
    best_fit_history = reshape(Convergence_curve, 1, numel(Convergence_curve));
    conv_curve = best_fit_history;

    %% Nested helper: safe objective evaluation
    function val = safe_eval(fun, x)
        % Ensure x is row and call fobj robustly
        x = reshape(x, 1, numel(x));
        try
            val = fun(x);
            if ~isnumeric(val) || isempty(val) || ~isreal(val)
                val = inf;
            end
            if isnan(val) || isinf(val)
                val = inf;
            end
        catch
            % any error in objective -> penalize heavily
            val = inf;
        end
    end
end
