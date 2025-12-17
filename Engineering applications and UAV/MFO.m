function [Best_pos, Best_score, Convergence_curve] = MFO(N, MaxFEs, lb, ub, dim, fobj)
    tic
    FEs = 0;
    it = 1;
    b = 1;  % 常数

    % 确保 lb 和 ub 是向量，与 dim 匹配
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    % 初始化种群
    X = lb + (ub - lb) .* rand(N, dim);  % 随机初始化种群
    fitness = inf * ones(N, 1);         % 初始化适应度值

    % 计算初始适应度
    for i = 1:N
        fitness(i) = fobj(X(i, :));  % 直接调用 fobj
        FEs = FEs + 1;
    end

    % 找到初始最优解
    [Best_score, BestIdx] = min(fitness);
    Best_pos = X(BestIdx, :);

    % 初始化收敛曲线
    Convergence_curve = zeros(1, ceil(MaxFEs / N));
    Convergence_curve(it) = Best_score;

    % 主循环
    while FEs <= MaxFEs
        t = FEs / MaxFEs; % 归一化进度
        r1 = 2 * (1 - t); % 动态参数调整
        flame_no = max(1, floor(N * (1 - t))); % 确保火焰数量不为 0

        % 更新每个飞蛾的位置
        for i = 1:N
            for d = 1:dim
                distance_to_flame = abs(Best_pos(d) - X(i, d));
                X(i, d) = distance_to_flame * exp(b * r1) * cos(2 * pi * r1) + Best_pos(d);
                % 保证位置在边界内
                X(i, d) = max(min(X(i, d), ub(d)), lb(d));
            end

            % 计算适应度
            fitness(i) = fobj(X(i, :));  % 直接调用 fobj
            FEs = FEs + 1;

            % 更新最优解
            if fitness(i) < Best_score
                Best_pos = X(i, :);
                Best_score = fitness(i);
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

    % 确保所有输出变量有值
    if ~exist('Best_pos', 'var') || isempty(Best_pos)
        Best_pos = X(1, :);
    end
    if ~exist('Best_score', 'var') || isempty(Best_score)
        Best_score = fitness(1);
    end
    if ~exist('Convergence_curve', 'var') || isempty(Convergence_curve)
        Convergence_curve = Best_score * ones(1, it);
    end

    toc
end