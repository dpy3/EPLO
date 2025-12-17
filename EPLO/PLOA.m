function [Best_score, Best_pos, Convergence_curve] = PLO(N, MaxFEs, lb, ub, dim, fobj)
% Polar Lights Optimizer (PLO) - 极光优化算法
% 基于极光现象的物理特性设计的元启发式优化算法
%
% 输入参数:
%   N: 种群大小
%   MaxFEs: 最大迭代次数
%   lb: 下界
%   ub: 上界  
%   dim: 维度
%   fobj: 目标函数
%
% 输出参数:
%   Best_score: 最优适应度值
%   Best_pos: 最优位置
%   Convergence_curve: 收敛曲线

    % 处理边界参数
    if length(lb) == 1
        lb = repmat(lb, 1, dim);
    end
    if length(ub) == 1
        ub = repmat(ub, 1, dim);
    end

    % 初始化种群
    X = lb + (ub - lb) .* rand(N, dim);
    
    % 计算初始适应度
    fitness = zeros(N, 1);
    for i = 1:N
        fitness(i) = fobj(X(i, :));
    end
    
    % 找到最优解
    [Best_score, best_idx] = min(fitness);
    Best_pos = X(best_idx, :);
    
    % 初始化收敛曲线
    Convergence_curve = zeros(1, MaxFEs);
    
    % PLO算法参数
    alpha = 2;      % 极光强度参数
    beta = 0.5;     % 磁场强度参数
    gamma = 0.1;    % 太阳风参数
    
    % 主循环
    for t = 1:MaxFEs
        % 动态参数调整
        a = 2 - 2 * t / MaxFEs;  % 线性递减参数
        
        % 极光强度 (Aurora Intensity)
        I = 2 * exp(-2 * t / MaxFEs);
        
        % 磁场强度 (Magnetic Field Strength)  
        B = 1 - t / MaxFEs;
        
        for i = 1:N
            % 选择三个随机个体
            r1 = randi(N); while r1 == i, r1 = randi(N); end
            r2 = randi(N); while r2 == i || r2 == r1, r2 = randi(N); end
            r3 = randi(N); while r3 == i || r3 == r1 || r3 == r2, r3 = randi(N); end
            
            % 极光粒子运动模型
            if rand < 0.5
                % 极光带运动 (Aurora Belt Movement)
                X_new = Best_pos + I * (X(r1, :) - X(r2, :)) + B * (X(r3, :) - X(i, :));
            else
                % 磁场偏转 (Magnetic Deflection)
                X_new = X(i, :) + alpha * rand(1, dim) .* (Best_pos - X(i, :)) + ...
                        beta * rand(1, dim) .* (X(r1, :) - X(r2, :));
            end
            
            % 太阳风扰动 (Solar Wind Perturbation)
            if rand < gamma
                X_new = X_new + 0.1 * randn(1, dim) .* (ub - lb);
            end
            
            % 边界处理
            for j = 1:dim
                if X_new(j) < lb(j)
                    X_new(j) = lb(j) + rand * (ub(j) - lb(j));
                elseif X_new(j) > ub(j)
                    X_new(j) = ub(j) - rand * (ub(j) - lb(j));
                end
            end
            
            % 计算新位置适应度
            fitness_new = fobj(X_new);
            
            % 贪婪选择
            if fitness_new < fitness(i)
                X(i, :) = X_new;
                fitness(i) = fitness_new;
                
                % 更新全局最优
                if fitness_new < Best_score
                    Best_score = fitness_new;
                    Best_pos = X_new;
                end
            end
        end
        
        % 极光爆发机制 (Aurora Burst Mechanism)
        if mod(t, 50) == 0 && t > MaxFEs/4
            % 随机选择一些个体进行大幅度变异
            burst_rate = 0.1; % 爆发率
            for i = 1:N
                if rand < burst_rate
                    % 大幅度随机变异
                    X(i, :) = lb + (ub - lb) .* rand(1, dim);
                    fitness(i) = fobj(X(i, :));
                    
                    % 更新全局最优
                    if fitness(i) < Best_score
                        Best_score = fitness(i);
                        Best_pos = X(i, :);
                    end
                end
            end
        end
        
        % 记录收敛曲线
        Convergence_curve(t) = Best_score;
        
        % 显示进度
        if mod(t, 50) == 0
            fprintf('PLO - 迭代 %d/%d, 最优值: %.6e\n', t, MaxFEs, Best_score);
        end
    end
    
    fprintf('PLO算法完成! 最终最优值: %.6e\n', Best_score);
end
