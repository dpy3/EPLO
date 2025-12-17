function [Best_score, Best_pos, Convergence_curve] = PSO(N, MaxFEs, lb, ub, dim, fobj)
    % 初始化参数
    pop_size = N;  % 种群规模
    max_function_evaluations = MaxFEs;  % 最大函数评估次数
    lower_bound = lb(:)';  % 下界
    upper_bound = ub(:)';  % 上界
    
    % 初始化种群位置和速度
    positions = lower_bound + (upper_bound - lower_bound) .* rand(pop_size, dim);
    velocities = zeros(pop_size, dim);

    % 初始化适应度值和个人最优、全局最优
    personal_best_positions = positions;
    personal_best_scores = arrayfun(@(i) fobj(positions(i, :)), 1:pop_size);
    [Best_score, best_idx] = min(personal_best_scores);
    Best_pos = positions(best_idx, :);

    % 收敛曲线初始化
    Convergence_curve = [];

    % 动态参数初始化
    inertia_max = 0.9;  % 惯性权重最大值
    inertia_min = 0.4;  % 惯性权重最小值
    c1 = 2;  % 学习因子1
    c2 = 2;  % 学习因子2

    function_evaluations = 0;

    % 主循环
    while function_evaluations < max_function_evaluations
        % 更新惯性权重
        inertia = inertia_max - ((inertia_max - inertia_min) / max_function_evaluations) * function_evaluations;

        % 更新粒子的速度和位置
        for i = 1:pop_size
            r1 = rand();  % 随机数1
            r2 = rand();  % 随机数2
            
            velocities(i, :) = inertia * velocities(i, :) ...
                + c1 * r1 .* (personal_best_positions(i, :) - positions(i, :)) ...
                + c2 * r2 .* (Best_pos - positions(i, :));
            
            positions(i, :) = positions(i, :) + velocities(i, :);

            % 边界处理
            positions(i, :) = max(min(positions(i, :), upper_bound), lower_bound);

            % 计算新位置的适应度
            new_fitness = fobj(positions(i, :));
            function_evaluations = function_evaluations + 1;

            if isnan(new_fitness) || isinf(new_fitness)
                new_fitness = inf;  % 处理无效适应度值
            end

            % 更新个人最优
            if new_fitness < personal_best_scores(i)
                personal_best_scores(i) = new_fitness;
                personal_best_positions(i, :) = positions(i, :);

                % 更新全局最优
                if new_fitness < Best_score
                    Best_score = new_fitness;
                    Best_pos = positions(i, :);
                end
            end

            % 记录收敛曲线
            Convergence_curve(end+1) = Best_score;

            % 提前终止条件检查（如果需要）
            if Best_score <= 0.003
                break;
            end
        end

        % 如果提前终止，则跳出主循环
        if Best_score <= 0.003
            break;
        end
    end
end