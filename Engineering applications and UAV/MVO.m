function [Best_pos, Best_score, Convergence_curve] = MVO(N, MaxFEs, lb, ub, dim, fobj)
    tic
    FEs = 0;
    it = 1;

    % 确保 lb 和 ub 是向量，与 dim 匹配
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    % 初始化
    white_holes = lb + (ub - lb) .* rand(N, dim);
    black_holes = lb + (ub - lb) .* rand(N, dim);
    wormholes_existence_rate = 0.5;
    travelling_distance_rate = 0.5;

    fitness_white = inf * ones(N, 1);
    fitness_black = inf * ones(N, 1);

    % 初始化收敛曲线
    Convergence_curve = [];

    % 默认最优解初始化
    Best_pos = zeros(1, dim);
    Best_score = inf;

    % 初始适应度计算
    for i = 1:N
        fitness_white(i) = fobj(white_holes(i, :)); % 直接调用 fobj
        fitness_black(i) = fobj(black_holes(i, :));
        FEs = FEs + 2;
    end

    % 找到初始最优解
    [Best_score, BestIdx] = min([fitness_white; fitness_black]);
    if BestIdx <= N
        Best_pos = white_holes(BestIdx, :);
    else
        Best_pos = black_holes(BestIdx - N, :);
    end

    Convergence_curve(it) = Best_score;

    % 主循环
    while FEs <= MaxFEs
        t = FEs / MaxFEs;
        TDR = travelling_distance_rate * (1 - t);

        for i = 1:N
            for d = 1:dim
                if rand() < wormholes_existence_rate
                    white_holes(i, d) = white_holes(i, d) + TDR * (black_holes(i, d) - white_holes(i, d));
                end
                % 确保解在范围内
                white_holes(i, d) = max(min(white_holes(i, d), ub(d)), lb(d));
            end
        end

        for i = 1:N
            % 重新计算适应度
            fitness_white(i) = fobj(white_holes(i, :)); % 直接调用 fobj
            FEs = FEs + 1;

            % 更新最优解
            if fitness_white(i) < Best_score
                Best_pos = white_holes(i, :);
                Best_score = fitness_white(i);
            end
        end

        % 更新收敛曲线
        it = it + 1;
        if it <= length(Convergence_curve)
            Convergence_curve(it) = Best_score;
        else
            Convergence_curve = [Convergence_curve, Best_score];
        end
    end

    % 确保所有输出变量都有值
    if ~exist('Best_pos', 'var') || isempty(Best_pos)
        Best_pos = white_holes(1, :);
    end
    if ~exist('Best_score', 'var') || isempty(Best_score)
        Best_score = fitness_white(1);
    end
    if ~exist('Convergence_curve', 'var') || isempty(Convergence_curve)
        Convergence_curve = Best_score * ones(1, it);
    end

    toc
end