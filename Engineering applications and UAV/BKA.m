% Black-winged Kite Algorithm (BKA) - corrected implementation
% Usage:
%   [Best_Pos, Best_Fitness, Convergence_curve] = BKA(pop, T, lb, ub, dim, fobj)
%
% Returns:
%   Best_Pos           - 1 x dim vector (best decision variables)
%   Best_Fitness       - scalar (best objective value)
%   Convergence_curve  - 1 x T vector (best fitness per iteration)
%
function [Best_Pos_BKA, Best_Fitness_BKA, Convergence_curve] = BKA(pop, T, lb, ub, dim, fobj)

    % --- Input robustness: convert scalar bounds to vectors if necessary
    if isscalar(lb)
        lb_vec = lb * ones(1, dim);
    else
        lb_vec = lb(:)'; % ensure row
    end
    if isscalar(ub)
        ub_vec = ub * ones(1, dim);
    else
        ub_vec = ub(:)'; % ensure row
    end

    % --- Initialize population
    XPos = initialization(pop, dim, ub_vec, lb_vec);  % pop x dim
    XFit = zeros(pop,1);

    % Evaluate initial fitness
    for i = 1:pop
        % ensure row vector input to objective
        xi = XPos(i,:);
        val = fobj(xi);
        % objective should return scalar; if not, take scalar conversion
        if isempty(val) || any(isnan(val))
            XFit(i) = NaN;
        else
            XFit(i) = val;
        end
    end

    % Initialize convergence history
    Convergence_curve = nan(1, T);

    % Find initial leader
    [minFit, minIdx] = min(XFit);
    Best_Fitness_BKA = minFit;
    Best_Pos_BKA = XPos(minIdx, :);
    if isnan(Best_Fitness_BKA)
        % if initial all NaN, set defaults
        Best_Fitness_BKA = Inf;
        Best_Pos_BKA = nan(1, dim);
    end

    % Main loop
    for t = 1:T
        % update leader each iteration
        [current_best_fit, best_idx] = min(XFit);
        if ~isempty(current_best_fit) && ~isnan(current_best_fit)
            XLeader_Fit = current_best_fit;
            XLeader_Pos = XPos(best_idx, :);
        else
            % if all NaN, keep previous best
            XLeader_Fit = Best_Fitness_BKA;
            XLeader_Pos = Best_Pos_BKA;
        end

        % dynamic parameters (you can tune these if needed)
        r = rand; % random scalar used for various behaviors

        for i = 1:pop
            % ---------- Attacking behavior ----------
            n = 0.05 * exp(-2 * (t / T)^2);  % small scaling factor
            if r < 0.9
                % multiplicative perturbation
                XPosNew = XPos(i,:) + n .* (1 + sin(rand)) .* XPos(i,:); 
            else
                % additive multiplicative perturbation
                XPosNew = XPos(i,:) .* (n .* (2*rand(1,dim) - 1) + 1);
            end

            % boundary check
            XPosNew = max(XPosNew, lb_vec);
            XPosNew = min(XPosNew, ub_vec);

            % evaluate
            fit_new = fobj(XPosNew);
            if isempty(fit_new) || any(isnan(fit_new))
                fit_new = NaN;
            end

            % accept improvement
            if ~isnan(fit_new) && (isnan(XFit(i)) || fit_new < XFit(i))
                XPos(i,:) = XPosNew;
                XFit(i) = fit_new;
            end

            % ---------- Migration behavior ----------
            m = 2 * sin(rand + pi/2);
            s = randi([1, pop]);          % random individual index in population
            r_XFitness = XFit(s);        % may be NaN

            ori_value = rand(1, dim);
            cauchy_value = tan((ori_value - 0.5) * pi); % Cauchy-like perturbation vector

            % If current fitness is better than sampled random individual's fitness,
            % move relative to leader using Cauchy perturbation; otherwise other rule.
            if ~isnan(XFit(i)) && ~isnan(r_XFitness) && (XFit(i) < r_XFitness)
                XPosNew2 = XPos(i,:) + cauchy_value .* (XPos(i,:) - XLeader_Pos);
            else
                XPosNew2 = XPos(i,:) + cauchy_value .* (XLeader_Pos - m .* XPos(i,:));
            end

            % boundary check
            XPosNew2 = max(XPosNew2, lb_vec);
            XPosNew2 = min(XPosNew2, ub_vec);

            % evaluate migration candidate
            fit_new2 = fobj(XPosNew2);
            if isempty(fit_new2) || any(isnan(fit_new2))
                fit_new2 = NaN;
            end

            % accept improvement
            if ~isnan(fit_new2) && (isnan(XFit(i)) || fit_new2 < XFit(i))
                XPos(i,:) = XPosNew2;
                XFit(i) = fit_new2;
            end
        end % end population loop

        % Update global best after population update
        [iter_best_fit, iter_best_idx] = min(XFit);
        if ~isempty(iter_best_fit) && ~isnan(iter_best_fit) && iter_best_fit < Best_Fitness_BKA
            Best_Fitness_BKA = iter_best_fit;
            Best_Pos_BKA = XPos(iter_best_idx, :);
        end

        % store convergence
        if isempty(Best_Fitness_BKA) || isnan(Best_Fitness_BKA)
            Convergence_curve(t) = NaN;
        else
            Convergence_curve(t) = Best_Fitness_BKA;
        end
    end % end iteration

    % final outputs:
    % Note: we return Best_Pos first (as your runner expects),
    %       then Best_Fitness, then Convergence_curve.
    % (Already stored as Best_Pos_BKA, Best_Fitness_BKA, Convergence_curve)

end % end function BKA

% ----------------------
% Helper: initialization
% ----------------------
function X = initialization(pop, dim, ub, lb)
    % ub, lb are row vectors of length dim
    % create pop-by-dim matrix of uniformly random samples in [lb,ub]
    if isscalar(ub)
        ub = ub * ones(1, dim);
    end
    if isscalar(lb)
        lb = lb * ones(1, dim);
    end
    % ensure row vectors
    ub = ub(:)'; lb = lb(:)';

    % random initialization
    X = repmat(lb, pop, 1) + rand(pop, dim) .* repmat((ub - lb), pop, 1);
end
