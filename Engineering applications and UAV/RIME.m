function [best_solution, best_fit_history, conv_curve] = RIME(N, Max_iter, lb, ub, dim, fobj)
% RIME - Robust implementation of the RIME optimizer compatible with run_type9
% Usage in run_type9:
%   [best_sol, best_fit_hist, conv_curve] = RIME(nPop, Max_iter, lb, ub, dim, fobj)
%
% Inputs:
%   N         - population size
%   Max_iter  - number of iterations
%   lb, ub    - scalar or 1-by-dim lower/upper bounds
%   dim       - problem dimensionality
%   fobj      - objective function handle: fitness = fobj(x) (x is 1-by-dim)
%
% Outputs:
%   best_solution     - 1-by-dim best solution found
%   best_fit_history  - 1-by-Max_iter best fitness history
%   conv_curve        - same as best_fit_history (alias)

    % --- Input normalization ---
    if isscalar(lb), lb = repmat(lb, 1, dim); end
    if isscalar(ub), ub = repmat(ub, 1, dim); end
    lb = reshape(lb, 1, dim);
    ub = reshape(ub, 1, dim);
    if any(lb > ub)
        error('RIME:BoundsError', 'Some lower bounds exceed upper bounds.');
    end

    % Pre-allocations
    Convergence_curve = nan(1, Max_iter);
    Best_rime = zeros(1, dim);
    Best_rime_rate = inf; % minimization problem

    % Initialize population uniformly in [lb, ub]
    Rimepop = rand(N, dim) .* (repmat(ub, N, 1) - repmat(lb, N, 1)) + repmat(lb, N, 1);

    % Evaluate initial fitness safely (protect against NaN/errors)
    Rime_rates = nan(1, N);
    for i = 1:N
        try
            val = fobj(Rimepop(i,:));
            if ~isnumeric(val) || ~isfinite(val)
                val = realmax * 1e-3; % big penalty
            end
        catch
            val = realmax * 1e-3;
        end
        Rime_rates(i) = val;
        if Rime_rates(i) < Best_rime_rate
            Best_rime_rate = Rime_rates(i);
            Best_rime = Rimepop(i,:);
        end
    end

    W = 5; % soft-rime parameter (paper)
    it = 1;

    % Main loop
    while it <= Max_iter
        % safe normalized Rime rates in [0,1] (higher -> worse)
        minR = min(Rime_rates);
        maxR = max(Rime_rates);
        denom = (maxR - minR) + eps;
        normalized_rime_rates = (Rime_rates - minR) ./ denom; % worst -> ~1, best -> ~0

        % Parameters
        RimeFactor = (rand - 0.5) * 2 * cos((pi * it / (Max_iter / 10))) * (1 - round(it * W / Max_iter) / W);
        E = sqrt(it / Max_iter);

        newRimepop = Rimepop; % copy

        for i = 1:N
            for j = 1:dim
                % Soft-rime search strategy
                r1 = rand();
                if r1 < E
                    % random value in [Lb(j), Ub(j)]
                    rand_in_range = (ub(j) - lb(j)) * rand() + lb(j);
                    newRimepop(i,j) = Best_rime(1,j) + RimeFactor * rand_in_range; % Eq.(3) variant
                end
                % Hard-rime puncture mechanism (worse individuals have larger normalized value)
                r2 = rand();
                if r2 < normalized_rime_rates(i)
                    newRimepop(i,j) = Best_rime(1,j); % move to best
                end
            end
        end

        % Boundary absorption (component-wise)
        newRimepop = max(newRimepop, repmat(lb, N, 1));
        newRimepop = min(newRimepop, repmat(ub, N, 1));

        % Evaluate new population safely
        newRime_rates = nan(1, N);
        for i = 1:N
            try
                val = fobj(newRimepop(i,:));
                if ~isnumeric(val) || ~isfinite(val)
                    val = realmax * 1e-3;
                end
            catch
                val = realmax * 1e-3;
            end
            newRime_rates(i) = val;
            % Greedy selection: accept if improved
            if newRime_rates(i) < Rime_rates(i)
                Rime_rates(i) = newRime_rates(i);
                Rimepop(i,:) = newRimepop(i,:);
                if Rime_rates(i) < Best_rime_rate
                    Best_rime_rate = Rime_rates(i);
                    Best_rime = Rimepop(i,:);
                end
            end
        end

        % Record convergence (ensure finite)
        if ~isfinite(Best_rime_rate)
            % if something went wrong and best is not finite, set to large number
            Best_rime_rate = realmax * 1e-3;
        end
        Convergence_curve(it) = Best_rime_rate;

        it = it + 1;
    end

    % Post-process Convergence_curve: replace any NaN with last valid or large value
    if any(isnan(Convergence_curve))
        lastValid = find(~isnan(Convergence_curve), 1, 'last');
        if isempty(lastValid)
            Convergence_curve(:) = realmax * 1e-3;
        else
            Convergence_curve(lastValid+1:end) = Convergence_curve(lastValid);
        end
    end

    % Prepare outputs in the order expected by run_type9
    best_solution = reshape(Best_rime, 1, dim);
    best_fit_history = reshape(Convergence_curve, 1, numel(Convergence_curve));
    conv_curve = best_fit_history; % alias
end
