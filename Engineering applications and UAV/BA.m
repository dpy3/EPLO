function [Best_pos, Best_score, Convergence_curve] = BA(nPop, Max_iter, lb, ub, dim, fobj)
    % 确保 lb 和 ub 是行向量
    lb = lb(:)'; % 确保是行向量
    ub = ub(:)';

    % 初始化参数
    xmin = lb;
    xmax = ub;
    Lb = xmin .* ones(1, dim); % 修改这里
    Ub = xmax .* ones(1, dim); % 修改这里
    Qmin = 0;
    Qmax = 2;
    alpha = 0.97;
    gamma = 0.5;
    pulse_rate = 0.5;
    freq_min = 0;
    freq_max = 2;
    solutions = xmin + rand(nPop, dim) .* (xmax - xmin);
    velocities = zeros(nPop, dim);
    fitness = zeros(nPop, 1);

    % 计算初始适应度值
    for i = 1:nPop
        fitness(i) = fobj(solutions(i, :).');
    end

    % 找到初始最优解
    [Best_score, BestIdx] = min(fitness);
    Best_pos = solutions(BestIdx, :);

    % 初始化收敛曲线
    Convergence_curve = zeros(1, Max_iter);
    Convergence_curve(1) = Best_score;

    % 主循环
    for t = 1:Max_iter
        for i = 1:nPop
            % 更新频率
            freq = freq_min + (freq_max - freq_min) * rand;

            % 更新速度
            velocities(i, :) = velocities(i, :) + (solutions(i, :) - Best_pos) * freq;

            % 更新位置
            solutions(i, :) = solutions(i, :) + velocities(i, :);

            % 边界检查
            solutions(i, :) = max(min(solutions(i, :), Ub), Lb);

            % 计算新解的适应度值
            new_fitness = fobj(solutions(i, :).');

            % 随机生成脉冲频率
            r = rand;
            if r > pulse_rate
                % 发生脉冲
                solutions(i, :) = Best_pos + 0.001 * randn(1, dim);
            end

            % 更新适应度值
            if new_fitness < fitness(i)
                solutions(i, :) = solutions(i, :);
                fitness(i) = new_fitness;
                if new_fitness < Best_score
                    Best_pos = solutions(i, :);
                    Best_score = new_fitness;
                end
            end
        end

        % 更新收敛曲线
        Convergence_curve(t) = Best_score;
    end
end