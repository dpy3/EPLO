function [Best_pos, Best_score, Convergence_curve] = GSA(N, MaxFEs, lb, ub, dim, fobj)
    tic
    FEs = 0;
    it = 1;
    G0 = 50;  % 初始引力常数
    alpha = 20;
    epsilon = 1e-15;

    % 确保 lb 和 ub 是向量，与 dim 匹配
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    % 初始化种群
    X = lb + (ub - lb) .* rand(N, dim);
    fitness = inf * ones(N, 1);

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
        G = G0 * (1 - FEs / MaxFEs);  % 动态调整引力常数
        masses = fitness / sum(fitness) + rand(size(fitness)) * 0.1;  % 增加随机因素
        forces = zeros(N, dim);

        % 计算每个粒子之间的引力和相互作用
        for i = 1:N
            for j = 1:N
                if i ~= j
                    rij = norm(X(i, :) - X(j, :)) + epsilon;  % 避免除以零
                    Fij = G * masses(i) * masses(j) / rij;  % 引力公式
                    forces(i, :) = forces(i, :) + Fij * (X(j, :) - X(i, :)) / rij;
                end
            end
        end

        % 更新粒子的位置和速度
        for i = 1:N
            X(i, :) = X(i, :) + forces(i, :) / masses(i);
            % 边界约束
            X(i, :) = max(min(X(i, :), ub), lb);
            fitness(i) = fobj(X(i, :));  % 直接调用 fobj
            FEs = FEs + 1;
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

    toc
end