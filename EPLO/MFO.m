function [Best_score, Best_pos, Convergence_curve] = MFO(pop, T, lb, ub, dim, fobj)
    tic;

    % 初始化参数
    FEs = 0;
    it = 1;
    b = 1;  % 常数

    % 确保 lb 和 ub 是向量，并且长度与 dim 相同
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    % 初始化种群及其适应度值
    X = lb + (ub - lb) .* rand(pop, dim); % 种群初始化
    fitness = inf(pop, 1);

    for i = 1:pop
        fitness(i) = fobj(X(i, :));
        FEs = FEs + 1;
    end

    % 找到初始最优解
    [Best_score, BestIdx] = min(fitness);
    Best_pos = X(BestIdx, :);

    % 初始化收敛曲线
    max_iterations = T;
    Convergence_curve = inf(1, max_iterations); % Initialize with inf to ensure all entries are updated
    Convergence_curve(it) = Best_score;

    while FEs <= pop * T && it <= max_iterations
        t = FEs / (pop * T);
        r1 = 2 * (1 - t);
        flame_no = floor(pop * (1 - t)) + 1;  % 确保 flame_no 是一个正整数
        if flame_no == 0
            flame_no = 1;  % 防止火焰数量为零
        end

        % 对每个飞蛾进行位置更新
        for i = 1:pop
            for d = 1:dim
                % 确保 flame_no 在有效范围内
                if flame_no > pop
                    flame_no = pop;
                end
                distance_to_flame = abs(X(flame_no, d) - X(i, d));
                X(i, d) = distance_to_flame * exp(b * r1) * cos(2 * pi * r1) + X(flame_no, d);
            end
            X(i, :) = max(min(X(i, :), ub), lb); % 边界检查
            fitness(i) = fobj(X(i, :)); % 计算新适应度值
            FEs = FEs + 1;
            if fitness(i) < Best_score
                Best_pos = X(i, :);
                Best_score = fitness(i);
            end
        end

        % 更新收敛曲线
        Convergence_curve(it) = min([Convergence_curve(it), Best_score]); % Ensure the curve is non-increasing
        it = it + 1;
    end

    % Fill any remaining entries in Convergence_curve with the last known best score
    if it <= max_iterations
        Convergence_curve(it:end) = Best_score;
    end

    toc;
end