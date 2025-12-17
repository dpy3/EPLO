function [Best_Fitness_ALO, Best_Pos_ALO, Convergence_curve_ALO] = ALO(pop, T, lb, ub, dim, fobj)
    tic;

    % 初始化参数
    FEs = 0;
    it = 1;

    % 确保 lb 和 ub 是向量，并且长度与 dim 相同
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    % 初始化蚂蚁位置和适应度值
    ants = lb + (ub - lb) .* rand(pop, dim);  % 按元素相乘
    fitness = inf(pop, 1);

    % 计算初始适应度值
    for i = 1:pop
        fitness(i) = fobj(ants(i, :));
        FEs = FEs + 1;
    end

    % 找到初始最优解
    [Best_Fitness_ALO, BestIdx] = min(fitness);
    Best_Pos_ALO = ants(BestIdx, :);

    % 初始化收敛曲线
    max_iterations = T; % 使用传入的最大迭代次数T
    Convergence_curve_ALO = inf(1, max_iterations); % Initialize with inf to ensure all entries are updated

    while FEs < pop * T && it <= max_iterations
        for i = 1:pop
            % 模拟蚂蚁的行为
            step_size = rand(1, dim) .* (Best_Pos_ALO - ants(i, :));  % 蚂蚁在当前最佳解周围的步长
            new_solution = ants(i, :) + step_size;  % 新解

            % 对新解进行边界检查
            new_solution = max(min(new_solution, ub), lb);

            % 计算新解的适应度值
            new_fitness = fobj(new_solution);
            FEs = FEs + 1;

            % 如果新解更好，更新当前位置和适应度值
            if new_fitness < fitness(i)
                ants(i, :) = new_solution;
                fitness(i) = new_fitness;
                if new_fitness < Best_Fitness_ALO
                    Best_Pos_ALO = new_solution;
                    Best_Fitness_ALO = new_fitness;
                end
            end
        end

        % 更新收敛曲线
        Convergence_curve_ALO(it) = min([Convergence_curve_ALO(it), Best_Fitness_ALO]); % Ensure the curve is non-increasing
        it = it + 1;

        % 提前终止条件（如果需要）
        % 这里假设提前终止条件对于所有测试函数都是可选的，因此被注释掉了
        % if Best_Fitness_ALO <= 0.003
        %     break;
        % end
    end

    % Fill any remaining entries in Convergence_curve_ALO with the last known best score
    if it <= max_iterations
        Convergence_curve_ALO(it:end) = Best_Fitness_ALO;
    end

    toc;
end