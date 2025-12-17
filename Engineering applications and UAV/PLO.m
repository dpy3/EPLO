function [Best_pos, Bestscore, Convergence_curve] = PLO(N, MaxFEs, lb, ub, dim, fhd, type)
    % Initialize parameters
    lb = lb(:)'; % Ensure lb is a row vector
    ub = ub(:)'; % Ensure ub is a row vector
    pos = lb + (ub - lb) .* rand(N, dim); % Initialize positions
    vel = zeros(N, dim);                  % Initialize velocities
    fitness = inf(N, 1);                  % Fitness values
    pBest = pos;                          % Individual best positions
    pBestScore = inf(N, 1);               % Individual best scores
    gBestScore = inf;                     % Global best score
    gBest = zeros(1, dim);                % Global best position

    % Convergence curve
    Convergence_curve = zeros(1, MaxFEs);

    % Dynamic weight parameters (lower range for stronger convergence)
    wMax = 0.6; wMin = 0.2;   % Smaller inertia weight for stronger convergence
    c1 = 2.5; c2 = 2.5;       % Increase acceleration constants for stronger local search

    % Main loop
    for t = 1:MaxFEs
        w = wMax - (wMax - wMin) * t / MaxFEs; % Dynamic inertia weight

        for i = 1:N
            % Update velocity and position
            vel(i, :) = w * vel(i, :) + ...
                        c1 * rand(1, dim) .* (pBest(i, :) - pos(i, :)) + ...
                        c2 * rand(1, dim) .* (gBest - pos(i, :));
            pos(i, :) = pos(i, :) + vel(i, :);

            % Boundary handling
            pos(i, :) = max(min(pos(i, :), ub), lb);

            % Calculate fitness
            fitness(i) = fhd(pos(i, :)');

            % Update individual best
            if fitness(i) < pBestScore(i)
                pBest(i, :) = pos(i, :);
                pBestScore(i) = fitness(i);
            end
        end

        % Update global best
        [current_gBestScore, idx] = min(pBestScore);
        if current_gBestScore < gBestScore
            gBestScore = current_gBestScore;
            gBest = pBest(idx, :);
        end

        % Record convergence curve
        Convergence_curve(t) = gBestScore;

        % Display progress every 10 iterations
        if mod(t, 10) == 0
            disp(['Iteration ', num2str(t), ': Best Fitness = ', num2str(gBestScore)]);
        end
    end

    % Return results
    Best_pos = gBest;
    Bestscore = gBestScore;  % Ensure this is a scalar value
end
