function [Best_score, Best_pos, Convergence_curve] = GSA(pop, T, lb, ub, dim, fobj)
    tic;

    % 初始化参数
    FEs = 0;
    it = 1;
    G0 = 50;  % 减小引力常数的初始值
    alpha = 20;
    epsilon = 1e-15;
    
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
        G = G0 * (1 - FEs / (pop * T)); % 更新引力常数
        masses = 1 ./ (fitness + epsilon); % 计算质量，避免除以零
        forces = zeros(pop, dim);

        % 计算所有个体之间的引力
        for i = 1:pop
            for j = 1:pop
                if i ~= j
                    rij = norm(X(i, :) - X(j, :)) + epsilon;
                    Fij = G * masses(i) * masses(j) / rij^2; % 引力公式修正
                    forces(i, :) = forces(i, :) + Fij * (X(j, :) - X(i, :)) / rij;
                end
            end
        end

        % 更新位置并计算新适应度值
        for i = 1:pop
            X(i, :) = X(i, :) + forces(i, :) / (masses(i) + epsilon); % 避免除以零
            X(i, :) = max(min(X(i, :), ub), lb); % 边界检查
            fitness(i) = fobj(X(i, :));
            FEs = FEs + 1;

            % 更新全局最优解
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