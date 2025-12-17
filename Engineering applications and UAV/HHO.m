function [Best_x, Best_score, cg_curve] = HHO(N, Max_iter, lb, ub, dim, fobj)
% HHO - Harris Hawks Optimization (simplified, robust)
% Usage:
%   [Best_x, Best_score, cg_curve] = HHO(N, Max_iter, lb, ub, dim, fobj)
%
% Outputs (order important!):
%   Best_x      - 1 x dim best solution vector (row)
%   Best_score  - scalar fitness value of Best_x
%   cg_curve    - 1 x Max_iter convergence curve (best fitness per iter)
%
% NOTE: The runner expects the FIRST output to be the solution vector.

    % ---- validate/prepare bounds ----
    if isscalar(lb), lb = lb * ones(1, dim); end
    if isscalar(ub), ub = ub * ones(1, dim); end
    lb = reshape(lb, 1, dim);
    ub = reshape(ub, 1, dim);

    % ---- initialization ----
    X = initialization(N, dim, ub, lb);      % N x dim
    fitness = inf(N, 1);

    for i = 1:N
        % evaluate initial fitness
        try
            fitness(i) = fobj(X(i, :));       % fobj should accept 1xdim vector
        catch
            % fallback: try column vector
            fitness(i) = fobj(X(i, :)');
        end
    end

    [Best_score, bestIdx] = min(fitness);
    Best_x = X(bestIdx, :);                  % row vector
    cg_curve = nan(1, Max_iter);

    % main loop
    for t = 1:Max_iter
        E1 = 2 * (1 - t / Max_iter);  % energy decline factor
        % compute population mean used in some strategies
        X_mean = mean(X, 1);

        for i = 1:N
            r1 = rand(); r2 = rand(); r3 = rand();
            E0 = 2 * rand() - 1;                 % random in [-1,1]
            EscapingEnergy = E1 * (2 * rand() - 1); % E in [-E1, E1]

            % exploration vs exploitation
            if abs(EscapingEnergy) >= 1
                % -------- Exploration phase --------
                if rand() < 0.5
                    % perch randomly around other hawk
                    rand_hawk = randi(N);
                    X(i, :) = X(rand_hawk, :) - rand() * abs(X(rand_hawk, :) - 2 * rand() .* X(i, :));
                else
                    % perch randomly around average
                    X(i, :) = (Best_x - X_mean) - rand() * (lb + rand(1, dim) .* (ub - lb));
                end
            else
                % -------- Exploitation phase (besiege) --------
                q = rand();
                if q >= 0.5 && abs(EscapingEnergy) < 0.5
                    % soft besiege
                    X(i, :) = Best_x - EscapingEnergy * abs(Best_x - X(i, :));
                elseif q >= 0.5 && abs(EscapingEnergy) >= 0.5
                    % hard besiege
                    X(i, :) = Best_x - EscapingEnergy * abs(Best_x - X_mean);
                elseif q < 0.5 && abs(EscapingEnergy) >= 0.5
                    % hard besiege with progressive rapid dives (Levy flights)
                    Y = Best_x - EscapingEnergy * abs(Best_x - X(i, :));
                    Y = bound_check(Y, lb, ub);
                    % perform Levy flight
                    LF = levy(dim);
                    Z = Y + rand(1, dim) .* LF;
                    % evaluate and choose better one
                    fY = try_eval(fobj, Y);
                    fZ = try_eval(fobj, Z);
                    if fY < fZ
                        X(i, :) = Y;
                    else
                        X(i, :) = Z;
                    end
                else
                    % soft besiege with Levy
                    Y = Best_x - EscapingEnergy * abs(Best_x - X(i, :));
                    Z = Y + rand(1, dim) .* levy(dim);
                    fY = try_eval(fobj, Y);
                    fZ = try_eval(fobj, Z);
                    if fY < fZ
                        X(i, :) = Y;
                    else
                        X(i, :) = Z;
                    end
                end
            end

            % boundary control
            X(i, :) = bound_check(X(i, :), lb, ub);

            % evaluate new fitness
            fnew = try_eval(fobj, X(i, :));
            if fnew < fitness(i)
                fitness(i) = fnew;
            end

            % update global best
            if fitness(i) < Best_score
                Best_score = fitness(i);
                Best_x = X(i, :);
            end
        end % end agents loop

        % store best for this iteration
        cg_curve(t) = Best_score;
        fprintf('HHO iter %d/%d  Best = %.6e\n', t, Max_iter, Best_score);
    end

    % ensure cg_curve has no NaN (if any leftover)
    if any(isnan(cg_curve))
        lastval = cg_curve(find(~isnan(cg_curve), 1, 'last'));
        if isempty(lastval), lastval = Best_score; end
        cg_curve(isnan(cg_curve)) = lastval;
    end

    % ensure outputs are in expected formats
    Best_x = reshape(Best_x, 1, dim);
    Best_score = Best_score;

    % -------------------------
    % nested / local helper functions
    % -------------------------
    function X0 = initialization(nPop, dim0, ub0, lb0)
        % creates nPop x dim matrix in [lb, ub]
        % ub0 and lb0 are 1xdim
        X0 = repmat(lb0, nPop, 1) + rand(nPop, dim0) .* (repmat(ub0 - lb0, nPop, 1));
    end

    function out = levy(d)
        % Mantegna's algorithm for Levy flights
        beta = 1.5;
        sigma_u = ( gamma(1 + beta) * sin(pi * beta / 2) / ...
            ( gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2) ) )^(1 / beta);
        u = randn(1, d) * sigma_u;
        v = randn(1, d);
        step = u ./ (abs(v).^(1 / beta));
        out = 0.01 * step; % scale factor (small step)
    end

    function vec = bound_check(vec, LB, UB)
        % clip vector to bounds (works both scalar and vector)
        vec = max(vec, LB);
        vec = min(vec, UB);
    end

    function val = try_eval(fun, xvec)
        % robust evaluation (try row, try column)
        try
            val = fun(xvec);
        catch
            val = fun(xvec(:));
        end
        % ensure scalar
        if numel(val) > 1
            val = val(end);
        end
    end

end
