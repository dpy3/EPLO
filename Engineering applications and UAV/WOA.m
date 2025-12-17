% Whale Optimization Algorithm (WOA) - Modified to return [best_pos, best_score, Convergence_curve]
% Signature matches runner that expects (solution_vector, fitness_scalar, convergence_curve)
function [best_pos, best_score, Convergence_curve] = WOA(SearchAgents_no, Max_iter, lb, ub, dim, fobj)
% WOA - Whale Optimization Algorithm
% Inputs:
%   SearchAgents_no - population size
%   Max_iter        - maximum iterations
%   lb, ub          - lower and upper bounds (scalar or 1 x dim vectors)
%   dim             - problem dimension
%   fobj            - handle to objective function (accepts 1 x dim vector)
% Outputs:
%   best_pos        - 1 x dim best solution vector found
%   best_score      - scalar best fitness (lower is better)
%   Convergence_curve - 1 x Max_iter convergence history (best_score each iter)

    % Ensure lb and ub are row vectors of length dim
    if isscalar(lb)
        lb = lb * ones(1, dim);
    else
        lb = lb(:)'; % row
    end
    if isscalar(ub)
        ub = ub * ones(1, dim);
    else
        ub = ub(:)'; % row
    end

    % Initialize leader (best)
    best_pos = zeros(1, dim);
    best_score = inf; % for minimization

    % Initialize population
    Positions = initialization(SearchAgents_no, dim, ub, lb); % returns SearchAgents_no x dim
    Convergence_curve = nan(1, Max_iter);

    t = 0;

    % Main loop
    while t < Max_iter
        for i = 1:SearchAgents_no
            % Clamp (safety)
            Positions(i, :) = min(max(Positions(i, :), lb), ub);

            % Evaluate
            try
                fitness = fobj(Positions(i, :)); % objective must accept row vector
            catch innerME
                % If objective throws, record large penalty
                warning('Objective function error for agent %d at iter %d: %s', i, t, innerME.message);
                fitness = inf;
            end

            % Update leader if better
            if fitness < best_score
                best_score = fitness;
                best_pos = Positions(i, :);
            end
        end

        % Linearly decreasing parameters
        a = 2 - t * (2 / Max_iter);       % a decreases from 2 to 0
        a2 = -1 + t * ((-1) / Max_iter);  % a2 decreases from -1 to -2

        % Update positions
        for i = 1:SearchAgents_no
            r1 = rand(1, dim);
            r2 = rand(1, dim);

            A = 2 .* a .* r1 - a;      % Eq. (2.3)
            C = 2 .* r2;              % Eq. (2.4)

            b = 1;
            l = (a2 - 1) * rand + 1;  % scalar
            p = rand();

            if p < 0.5
                % Exploitation & exploration (depending on |A|)
                if any(abs(A) >= 1)
                    % Choose random search agent
                    rand_index = randi([1, SearchAgents_no]);
                    X_rand = Positions(rand_index, :);
                    D_X_rand = abs(C .* X_rand - Positions(i, :));
                    Positions(i, :) = X_rand - A .* D_X_rand;
                else
                    % Shrink towards leader
                    D_leader = abs(C .* best_pos - Positions(i, :));
                    Positions(i, :) = best_pos - A .* D_leader;
                end
            else
                % Spiral updating position (exploitation)
                distance2Leader = abs(best_pos - Positions(i, :));
                Positions(i, :) = distance2Leader .* exp(b .* l) .* cos(2 * pi * l) + best_pos;
            end

            % Ensure within bounds after update
            Positions(i, :) = min(max(Positions(i, :), lb), ub);
        end

        t = t + 1;
        Convergence_curve(t) = best_score;

        % (optional) display progress: uncomment if you want iteration printout
        % fprintf('WOA iter %d, best = %.4e\n', t, best_score);
    end

    % final outputs: ensure best_pos is 1 x dim and Convergence_curve full length
    best_pos = best_pos(:)'; % row
    if length(Convergence_curve) < Max_iter
        Convergence_curve(length(Convergence_curve)+1:Max_iter) = Convergence_curve(length(Convergence_curve));
    end
end

%% Helper: initialization
function Positions = initialization(SearchAgents_no, dim, ub, lb)
% Return matrix SearchAgents_no x dim with positions between lb and ub
    Positions = zeros(SearchAgents_no, dim);

    % ub and lb should be 1 x dim
    if isscalar(ub)
        ub = ub * ones(1, dim);
    end
    if isscalar(lb)
        lb = lb * ones(1, dim);
    end

    for j = 1:dim
        ub_j = ub(j);
        lb_j = lb(j);
        Positions(:, j) = rand(SearchAgents_no, 1) .* (ub_j - lb_j) + lb_j;
    end
end
