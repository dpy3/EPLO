function [Best_score, Best_pos, curve] = FOX(SearchAgents_no, Max_iter, lb, ub, dim, fobj)
% FOX 算法主函数
% 输入:
%   SearchAgents_no - 种群大小
%   Max_iter        - 最大迭代次数
%   lb, ub          - 搜索空间上下界 (1×dim 向量 或 标量)
%   dim             - 问题维度
%   fobj            - 目标函数句柄，接收 1×dim 行向量
% 输出:
%   Best_score      - 最终全局最优适应度
%   Best_pos        - 最终全局最优位置 (1×dim)
%   curve           - 收敛曲线 (1×Max_iter)

    %-------------------- 初始化 --------------------%
    Best_pos   = zeros(1, dim);
    Best_score = inf;       % 对于最小化问题
    MinT       = inf;       % 用于随机游走步长
    X = initialization(SearchAgents_no, dim, ub, lb);  % 种群位置矩阵 (N×dim)
    
    Distance_Fox_Rat = zeros(SearchAgents_no, dim);
    curve = zeros(1, Max_iter);
    
    % c1, c2 控制两种跳跃模式
    c1 = 0.18;
    c2 = 0.82;
    
    %-------------------- 主循环 --------------------%
    for l = 1:Max_iter
        
        %—— 越界处理 & 适应度计算 ——%
        for i = 1:SearchAgents_no
            % 越界校正
            X(i, :) = max(min(X(i, :), ub), lb);
            % 计算适应度
            fitness = fobj(X(i, :));
            % 更新全局最优
            if fitness < Best_score
                Best_score = fitness;
                Best_pos   = X(i, :);
            end
        end
        
        %—— 计算渐变参数 ——%
        a = 2 * (1 - l/Max_iter);
        
        %—— 更新每个个体 ——%
        for i = 1:SearchAgents_no
            r = rand;
            p = rand;
            
            if r >= 0.5
                % Fox 跳跃
                Time = rand(1, dim);
                
                % 逐元素操作
                sps = Best_pos ./ Time;                 
                Distance_S_Travel = sps .* Time;        
                Distance_Fox_Rat(i, :) = 0.5 * Distance_S_Travel;
                
                tt = mean(Time);
                MinT = min(MinT, tt);
                Jump = 0.5 * 9.81 * (tt/2)^2;
                
                if p > c1
                    X(i, :) = Distance_Fox_Rat(i, :) .* Jump * c1;
                else
                    X(i, :) = Distance_Fox_Rat(i, :) .* Jump * c2;
                end
                
            else
                % 随机游走
                X(i, :) = Best_pos + randn(1, dim) .* (MinT * a);
            end
        end
        
        % 记录收敛曲线
        curve(l) = Best_score;
    end
end

%% 辅助函数：初始化种群
function X = initialization(SearchAgents_no, dim, ub, lb)
    % 如果 ub/lb 为标量
    if isscalar(ub) && isscalar(lb)
        X = rand(SearchAgents_no, dim) .* (ub - lb) + lb;
    else
        % ub, lb 为 1×dim 向量
        X = zeros(SearchAgents_no, dim);
        for j = 1:dim
            X(:, j) = rand(SearchAgents_no, 1) .* (ub(j) - lb(j)) + lb(j);
        end
    end
end
