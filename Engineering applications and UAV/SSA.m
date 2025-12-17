function [Best_pos, Best_score, Convergence_curve] = SSA(N, MaxFEs, lb, ub, dim, fobj, fun_no)
    tic
    FEs = 0; % 函数调用计数
    it = 1; % 迭代计数

    % 确保 lb 和 ub 是向量，并且长度与 dim 相同
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    % 初始化 Salp 群体
    salps = lb + (ub - lb) .* rand(N, dim);
    fitness = zeros(N, 1);

    % 初始化适应度值
    for i = 1:N
        fitness(i) = fobj(salps(i, :)', fun_no); % 确保列向量形式
        FEs = FEs + 1;
    end

    % 找到初始最佳解
    [Bestscore, BestIdx] = min(fitness);
    Bestpos = salps(BestIdx, :);

    % 初始化收敛曲线
    Convergence_curve = zeros(1, ceil(MaxFEs / N));
    Convergence_curve(it) = Bestscore;

    % 主循环
    while FEs <= MaxFEs
        for i = 1:N
            if i == 1
                % 领导 Salp 更新
                c1 = 2 * exp(-(4 * it / MaxFEs)^2);
                for j = 1:dim
                    if rand() < 0.5
                        salps(i, j) = Bestpos(j) + c1 * ((ub(j) - lb(j)) * rand() + lb(j));
                    else
                        salps(i, j) = Bestpos(j) - c1 * ((ub(j) - lb(j)) * rand() + lb(j));
                    end
                    % 保持在边界内
                    salps(i, j) = max(min(salps(i, j), ub(j)), lb(j));
                end
            else
                % 跟随 Salp 更新
                for j = 1:dim
                    salps(i, j) = (salps(i-1, j) + salps(i, j)) / 2;
                    % 保持在边界内
                    salps(i, j) = max(min(salps(i, j), ub(j)), lb(j));
                end
            end

            % 计算新的适应度值
            new_fitness = fobj(salps(i, :)', fun_no); % 确保列向量形式
            FEs = FEs + 1;

            % 更新适应度值
            fitness(i) = new_fitness;
            if new_fitness < Bestscore
                Bestpos = salps(i, :);
                Bestscore = new_fitness;
            end
        end

        % 更新收敛曲线
        it = it + 1;
        if it <= length(Convergence_curve)
            Convergence_curve(it) = Bestscore;
        end
    end

    % 确保所有输出变量都有值
    if ~exist('Best_pos', 'var') || isempty(Best_pos)
        Best_pos = salps(1, :);
    end
    if ~exist('Best_score', 'var') || isempty(Best_score)
        Best_score = fitness(1);
    end
    if ~exist('Convergence_curve', 'var') || isempty(Convergence_curve)
        Convergence_curve = Bestscore * ones(1, it);
    end

    toc
end
