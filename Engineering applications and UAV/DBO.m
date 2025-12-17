function [best_solution, best_fit_history, conv_curve] = DBO(pop, M, lb, ub, dim, fobj)
% DBO - safe, vectorized and run_type9-compatible implementation
% Usage in run_type9: [best_sol, best_fit_hist, conv_curve] = DBO(nPop, Max_iter, lb, ub, dim, fobj)
%
% Inputs:
%   pop - population size (integer)
%   M   - max iterations
%   lb  - lower bound (scalar or 1-by-dim vector)
%   ub  - upper bound (scalar or 1-by-dim vector)
%   dim - problem dimension
%   fobj- objective handle: fitness = fobj(x) where x is 1-by-dim
%
% Outputs:
%   best_solution      - 1-by-dim best position found
%   best_fit_history   - 1-by-M history of best fitness (convergence)
%   conv_curve         - same as best_fit_history (keeps naming compatibility)

    % --- Input validation ---
    if pop < 3
        error('DBO:popTooSmall', 'Population size pop must be >= 3.');
    end
    if M < 1
        error('DBO:InvalidIter', 'M (max iterations) must be >= 1.');
    end

    % Ensure lb/ub are row vectors of length dim
    if isscalar(lb), lb = repmat(lb,1,dim); end
    if isscalar(ub), ub = repmat(ub,1,dim); end
    lb = reshape(lb,1,dim);
    ub = reshape(ub,1,dim);

    % producers proportion (can be tuned)
    P_percent = 0.2;
    pNum = max(1, round(pop * P_percent));

    % Pre-allocations
    x = zeros(pop, dim);
    pX = zeros(pop, dim);
    fit = inf(pop,1);
    pFit = inf(pop,1);

    % Initialization (uniform random within bounds)
    for i = 1:pop
        x(i,:) = lb + (ub - lb) .* rand(1, dim);
        fit(i) = fobj(x(i,:));
    end
    pFit = fit;
    pX = x;
    XX = pX;  % previous personal positions

    [fMin, bestI] = min(fit);
    bestX = x(bestI, :);

    Convergence_curve = nan(1, M);

    % --- Main loop ---
    for t = 1:M
        [~, B] = max(fit);
        worse = x(B, :);
        r2 = rand();

        % 1) Update producers (1 : pNum)
        for i = 1:pNum
            if r2 < 0.9
                a = rand();
                if a > 0.1
                    a = 1;
                else
                    a = -1;
                end
                x(i,:) = pX(i,:) + 0.3 * abs(pX(i,:) - worse) + a * 0.1 * XX(i,:);
            else
                % select an integer angle in [1,180]
                aaa = randi(180,1);
                theta = aaa * pi / 180;
                x(i,:) = pX(i,:) + tan(theta) .* abs(pX(i,:) - XX(i,:));
            end
            x(i,:) = Bounds(x(i,:), lb, ub);
            fit(i) = fobj(x(i,:));
        end

        % 2) compute shrinking/expansion points
        [~, bestII] = min(fit);
        bestXX = x(bestII, :);
        R = 1 - t / M;

        Xnew1 = bestXX .* (1 - R);
        Xnew2 = bestXX .* (1 + R);
        Xnew1 = Bounds(Xnew1, lb, ub);
        Xnew2 = Bounds(Xnew2, lb, ub);

        Xnew11 = bestX .* (1 - R);
        Xnew22 = bestX .* (1 + R);
        Xnew11 = Bounds(Xnew11, lb, ub);
        Xnew22 = Bounds(Xnew22, lb, ub);

        % 3) Partition remaining individuals into 3 adaptive groups
        remaining = pop - pNum;
        if remaining > 0
            % Tunable split ratios (sums to <=1; remainder goes to group C)
            pA = 0.45; pB = 0.25; % group C receives rest
            groupA_size = min(remaining, floor(remaining * pA));
            groupB_size = min(remaining - groupA_size, floor(remaining * pB));
            groupC_size = remaining - groupA_size - groupB_size;

            idx = pNum + 1;

            % Group A: variant of Eq (4)
            for k = 1:groupA_size
                i = idx; idx = idx + 1;
                x(i,:) = bestXX + ((rand(1, dim)) .* (pX(i,:) - Xnew1) + (rand(1, dim)) .* (pX(i,:) - Xnew2));
                lowerBound = min(Xnew1, Xnew2);
                upperBound = max(Xnew1, Xnew2);
                x(i,:) = Bounds(x(i,:), lowerBound, upperBound);
                fit(i) = fobj(x(i,:));
            end

            % Group B: variant of Eq (6)
            for k = 1:groupB_size
                i = idx; idx = idx + 1;
                x(i,:) = pX(i,:) + ((randn(1, dim)) .* (pX(i,:) - Xnew11) + (rand(1, dim)) .* (pX(i,:) - Xnew22));
                x(i,:) = Bounds(x(i,:), lb, ub);
                fit(i) = fobj(x(i,:));
            end

            % Group C: variant of Eq (7) (exploit around best)
            for k = 1:groupC_size
                i = idx; idx = idx + 1;
                x(i,:) = bestX + randn(1, dim) .* ((abs((pX(i,:) - bestXX))) + (abs((pX(i,:) - bestX)))) ./ 2;
                x(i,:) = Bounds(x(i,:), lb, ub);
                fit(i) = fobj(x(i,:));
            end
        end

        % 4) Update personal bests & global best
        XX = pX;
        for i = 1:pop
            if fit(i) < pFit(i)
                pFit(i) = fit(i);
                pX(i,:) = x(i,:);
            end
            if pFit(i) < fMin
                fMin = pFit(i);
                bestX = pX(i,:);
            end
        end

        Convergence_curve(t) = fMin;
    end

    % Prepare outputs in the order expected by run_type9
    best_solution = reshape(bestX, 1, dim);
    % Ensure history vectors are 1-by-M and contain no NaN
    if any(isnan(Convergence_curve))
        % replace trailing NaNs by last valid value or Inf if none
        lastValid = find(~isnan(Convergence_curve),1,'last');
        if isempty(lastValid)
            Convergence_curve(:) = Inf;
        else
            Convergence_curve(lastValid+1:end) = Convergence_curve(lastValid);
        end
    end
    best_fit_history = reshape(Convergence_curve, 1, numel(Convergence_curve));
    conv_curve = best_fit_history; % maintain both outputs as same convergence curve
end

%% Local bounds helper (subfunction)
function s = Bounds(s, Lb, Ub)
    % Accept scalar or vector bounds, perform component-wise clipping
    if isscalar(Lb), Lb = repmat(Lb, 1, numel(s)); end
    if isscalar(Ub), Ub = repmat(Ub, 1, numel(s)); end
    s(s < Lb) = Lb(s < Lb);
    s(s > Ub) = Ub(s > Ub);
end
