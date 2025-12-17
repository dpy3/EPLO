function [Best_pos, Best_score, Convergence_curve] = ALO(N, MaxFEs, lb, ub, dim, fobj)
    tic
    FEs = 0;
    it = 1;

    % 确保 lb 和 ub 是向量，并且长度与 dim 相同
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    % 初始化
    ants = lb + (ub - lb) .* rand(N, dim);  % 按元素相乘
    fitness = inf * ones(N, 1);

    % 计算初始适应度值
    for i = 1:N
        fitness(i) = fobj(ants(i, :).');
        FEs = FEs + 1;
    end

    % 找到初始最优解
    [Best_score, BestIdx] = min(fitness);
    Best_pos = ants(BestIdx, :);

    % 初始化收敛曲线
    Convergence_curve = zeros(1, ceil(MaxFEs / N));
    Convergence_curve(it) = Best_score;

    % 主循环
    while FEs <= MaxFEs
        for i = 1:N
            % 模拟蚂蚁的行为
            step_size = rand(1, dim) .* (Best_pos - ants(i, :));  % 蚂蚁在当前最佳解周围的步长
            new_solution = ants(i, :) + step_size;  % 新解

            % 对新解进行边界检查
            new_solution = max(min(new_solution, ub), lb);

            % 计算新解的适应度值
            new_fitness = fobj(new_solution.');
            FEs = FEs + 1;

            % 如果新解更好，更新当前位置和适应度值
            if new_fitness < fitness(i)
                ants(i, :) = new_solution;
                fitness(i) = new_fitness;
                if new_fitness < Best_score
                    Best_pos = new_solution;
                    Best_score = new_fitness;
                end
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

    % 确保 Best_score 是标量
    if ~isscalar(Best_score)
        error('Best_score must be a scalar value.');
    end

    toc
end