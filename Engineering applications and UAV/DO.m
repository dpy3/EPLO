%__________________________________________________________________
%  Dandelion Optimizer (modified for run_type9 compatibility)
%  Based on: Zhao et al., "Dandelion Optimizer..."
%__________________________________________________________________
function [best_solution, best_fit_history, conv_curve] = DO(Popsize, Maxiteration, LB, UB, Dim, Fobj)
% DO - Dandelion Optimizer wrapper compatible with run_type9
% Returns:
%   best_solution      : 1 x Dim (best variable vector)
%   best_fit_history   : 1 x Maxiteration (best fitness per iter)
%   conv_curve         : same as best_fit_history (alias)
%
% Usage in run_type9:
%   [best_sol, best_fit_hist, conv_curve] = DO(nPop, Max_iter, lb, ub, dim, fobj);

    % --- Input validation & normalize LB/UB to 1-by-Dim ---
    if Popsize < 1 || Maxiteration < 1
        error('DO:InvalidInput','Popsize and Maxiteration must be positive integers.');
    end
    if isscalar(LB), LB = repmat(LB, 1, Dim); end
    if isscalar(UB), UB = repmat(UB, 1, Dim); end
    LB = reshape(LB, 1, Dim);
    UB = reshape(UB, 1, Dim);
    % ensure LB <= UB elementwise
    if any(LB > UB)
        error('DO:Bounds','Some LB elements are greater than UB elements.');
    end

    % --- Pre-allocations ---
    Convergence_curve = inf(1, Maxiteration);
    % initialize population uniformly in [LB, UB]
    dandelions = rand(Popsize, Dim) .* (repmat(UB, Popsize, 1) - repmat(LB, Popsize, 1)) + repmat(LB, Popsize, 1);
    dandelionsFitness = zeros(1, Popsize);

    % evaluate initial fitness
    for i = 1:Popsize
        % ensure row vector
        xi = reshape(dandelions(i,:), 1, Dim);
        dandelionsFitness(i) = Fobj(xi);
    end

    % sort and record best
    [sorted_vals, sorted_idx] = sort(dandelionsFitness);
    Best_position = dandelions(sorted_idx(1), :);
    Best_fitness = sorted_vals(1);
    Convergence_curve(1) = Best_fitness;

    t = 2;
    % main loop
    while t <= Maxiteration
        % Rising stage params
        beta = randn(Popsize, Dim);
        alpha = rand() * ((1 / Maxiteration^2) * t^2 - 2 / Maxiteration * t + 1); % eq.(8)
        a = 1 / (Maxiteration^2 - 2 * Maxiteration + 1);
        b = -2 * a;
        c = 1 - a - b;
        k = 1 - rand() * (c + a * t^2 + b * t); % eq.(11)

        if randn() < 1.5
            % variant with log-normal weighting
            for i = 1:Popsize
                lamb = abs(randn(1, Dim));
                theta = (2 * rand() - 1) * pi;
                row = 1 / exp(theta);
                vx = row * cos(theta);
                vy = row * sin(theta);
                NEW = rand(1, Dim) .* (UB - LB) + LB;
                % lognpdf: use MATLAB's lognpdf if available; else approximate via exp of normal
                % Use lognpdf assuming Statistics Toolbox; otherwise use exp(-0.5*lamb.^2)/sqrt(2*pi) as fallback
                try
                    w = lognpdf(lamb, 0, 1); % preferred
                catch
                    w = exp(-0.5 * (lamb.^2)) / sqrt(2 * pi); % fallback approximation
                end
                dandelions_1(i, :) = dandelions(i, :) + alpha .* vx .* vy .* w .* (NEW - dandelions(i, :)); % eq.(5)
            end
        else
            % simple contraction
            for i = 1:Popsize
                dandelions_1(i, :) = dandelions(i, :) .* k; % eq.(10)
            end
        end
        dandelions = dandelions_1;
        % enforce bounds (per-dim)
        dandelions = max(dandelions, repmat(LB, Popsize, 1));
        dandelions = min(dandelions, repmat(UB, Popsize, 1));

        % Decline stage
        dandelions_mean = sum(dandelions, 1) / Popsize; % eq.(14)
        dandelions_2 = zeros(size(dandelions));
        for i = 1:Popsize
            for j = 1:Dim
                dandelions_2(i, j) = dandelions(i, j) - beta(i, j) * alpha * (dandelions_mean(1, j) - beta(i, j) * alpha * dandelions(i, j)); % eq.(13)
            end
        end
        dandelions = dandelions_2;
        dandelions = max(dandelions, repmat(LB, Popsize, 1));
        dandelions = min(dandelions, repmat(UB, Popsize, 1));

        % Landing stage
        Step_length = levy(Popsize, Dim, 1.5);
        Elite = repmat(Best_position, Popsize, 1);
        dandelions_3 = zeros(size(dandelions));
        for i = 1:Popsize
            for j = 1:Dim
                dandelions_3(i, j) = Elite(i, j) + Step_length(i, j) * alpha * (Elite(i, j) - dandelions(i, j) * (2 * t / Maxiteration)); % eq.(15)
            end
        end
        dandelions = dandelions_3;
        dandelions = max(dandelions, repmat(LB, Popsize, 1));
        dandelions = min(dandelions, repmat(UB, Popsize, 1));

        % Evaluate fitness after updates
        for i = 1:Popsize
            dandelionsFitness(i) = Fobj(reshape(dandelions(i, :), 1, Dim));
        end

        % Sort by fitness and update best
        [SortfitbestN, sorted_indexes] = sort(dandelionsFitness);
        dandelions = dandelions(sorted_indexes(1:Popsize), :);

        if SortfitbestN(1) < Best_fitness
            Best_position = dandelions(1, :);
            Best_fitness = SortfitbestN(1);
        end

        Convergence_curve(t) = Best_fitness;
        t = t + 1;
    end

    % Ensure Convergence_curve length and no NaN
    if any(isnan(Convergence_curve))
        lastValid = find(~isnan(Convergence_curve), 1, 'last');
        if isempty(lastValid)
            Convergence_curve(:) = Inf;
        else
            Convergence_curve(lastValid+1:end) = Convergence_curve(lastValid);
        end
    end

    % Outputs in the order expected by run_type9
    best_solution = reshape(Best_position, 1, Dim);
    best_fit_history = reshape(Convergence_curve, 1, numel(Convergence_curve));
    conv_curve = best_fit_history; % alias

end

% -------------------------
function z = levy(n, m, beta)
    % Levy flight step generator
    % Use randn-based draws (avoids dependence on random('Normal',...) from Statistics Toolbox)
    num = gamma(1 + beta) * sin(pi * beta / 2);
    den = gamma((1 + beta) / 2) * beta * 2 ^ ((beta - 1) / 2);
    sigma_u = (num / den) ^ (1 / beta);
    % u ~ N(0, sigma_u^2), v ~ N(0,1)
    u = sigma_u .* randn(n, m);
    v = randn(n, m);
    z = u ./ (abs(v) .^ (1 / beta));
end
