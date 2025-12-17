function [Best_Score,Best_X,convergence_curve] = DAOA(pop_size, iter_max, lb, ub, dim, fhd)

    %%—— 参数检查：若 lb/ub 为标量，则扩展为长度为 dim 的向量 ——%%
    if isscalar(lb)
        lb = repmat(lb, 1, dim);
    end
    if isscalar(ub)
        ub = repmat(ub, 1, dim);
    end

    %%—— 对立学习初始化 ——%%
    % Step1: 普通随机初始化
    X = initialization(pop_size, dim, ub, lb);
    % Step2: 计算对立解并合并：X_opp(i,:) = lb + ub - X(i,:)
    X_opp = zeros(pop_size, dim);
    for i = 1:pop_size
        X_opp(i,:) = lb + ub - X(i,:);
    end
    % Step3: 评价原始种群与对立种群，选出每对中更优者
    Pop = zeros(pop_size, dim);
    Pop_Fit = zeros(1, pop_size);
    for i = 1:pop_size
        f1 = feval(fhd, X(i,:));
        f2 = feval(fhd, X_opp(i,:));
        if f1 <= f2
            Pop(i,:) = X(i,:);
            Pop_Fit(i) = f1;
        else
            Pop(i,:) = X_opp(i,:);
            Pop_Fit(i) = f2;
        end
    end

    % 全局最优初始化
    [Best_Score, idx0] = min(Pop_Fit);
    Best_X = Pop(idx0,:);

    convergence_curve = inf(1, iter_max);
    convergence_curve(1) = Best_Score;

    %%—— 其他参数初始化 ——%%
    x = 3 * rand(1, pop_size) / dim;
    m = 0.5 * rand(1, pop_size) / dim;
    L = (pop_size / dim) * rand(1, pop_size);
    e = m;
    g = 9.8 / dim;
    beta_levy = 1.5;      % Lévy 飞行中的 beta
    %%—— 迭代过程 ——%%
    for t = 1:iter_max
        % 1) 动态系数 c（与原AOO相同），但放慢衰减速度，避免过早开发
        c = (1 - t/iter_max)^2;    
        % 2) 计算 Lévy 飞行步长矩阵
        P = levy(pop_size, dim, beta_levy);

        % 3) 动态探索/开发概率：early_exploit 越大则越偏向开发
        %    迭代初期以 0.3 为起点，线性增长到 0.7
        exploit_prob = 0.3 + 0.4*(t/iter_max);

        for i = 1:pop_size
            r1 = rand();
            if r1 < exploit_prob
                %% —— 开发阶段 —— %%
                if rand() > 0.5
                    % —— 未遇障碍（滚动传播）R公式略作优化 —— %
                    A = ub - abs(ub .* (t/iter_max) .* sin(2*pi*rand()) );
                    R = ((m(i)*e(i) + L(i)^2) / dim) .* (2.*A.*rand(1, dim) - A);
                    % 新位置：Best_X + R + c*Lévy
                    X_new = Best_X + R + c * P(i,:) .* Best_X;
                else
                    % —— 遇障碍（弹射传播）J公式略作优化 —— %
                    k = 0.5 + 0.5*rand();
                    B = ub - abs(ub .* (t/iter_max) .* cos(2*pi*rand()));
                    alpha_e = (1/pi) * exp(randi([0,t])/iter_max);
                    theta = pi * rand();
                    J = (2 * k * x(i)^2 * sin(2*theta) / (m(i)*g)) ...
                        * ((1 - alpha_e)/dim) .* (2.*B.*rand(1, dim) - B);
                    X_new = Best_X + J + c * P(i,:) .* Best_X;
                end

                % —— 每隔 10% 迭代，对当前最优做小规模高斯微调 —— %
                if mod(t, ceil(iter_max*0.1)) == 0
                    % 只对 Best_X 本体作微调，不替代搜索主体
                    gauss_step = 0.01 * (ub - lb);
                    Best_X = Best_X + gauss_step .* randn(1, dim);
                    % 边界修复
                    Best_X = max(min(Best_X, ub), lb);
                    % 重新评估
                    f_tmp = feval(fhd, Best_X);
                    if f_tmp < Best_Score
                        Best_Score = f_tmp;
                    end
                end

            else
                %% —— 探索阶段 —— %%
                W = (c/pi) * (2*rand(1,dim) - 1) .* ub * (1 - t/iter_max);
                if mod(i, round(pop_size/10)) == 0
                    X_new = mean(Pop, 1) + W;
                elseif mod(i, round(pop_size/10)) == 1
                    X_new = Best_X + W;
                else
                    X_new = Pop(i,:) + W;
                end
            end

            % 边界检查
            X_new = boundaryCheck(X_new, lb, ub);

            % 评估新解并选择更新
            f_new = feval(fhd, X_new);
            if f_new < Pop_Fit(i)
                Pop(i,:) = X_new;
                Pop_Fit(i) = f_new;
            end

            % 更新全局最优
            if Pop_Fit(i) < Best_Score
                Best_Score = Pop_Fit(i);
                Best_X = Pop(i,:);
            end
        end

        % 记录当代最优
        convergence_curve(t) = Best_Score;
    end
end

%%—— 边界检查函数 ——%%
function x = boundaryCheck(x, lb, ub)
    % 支持对 1×dim 向量做边界修复
    x = max(min(x, ub), lb);
end

%%—— 初始化函数 ——%%
function X = initialization(N, dim, ub, lb)
    % 与原AOO相同逻辑：若 ub/lb 为标量，则全维度相同；否则每维单独生成
    Boundary_no = numel(ub);
    if Boundary_no == 1
        X = rand(N, dim) .* (ub - lb) + lb;
    else
        X = zeros(N, dim);
        for j = 1:dim
            X(:, j) = rand(N, 1) .* (ub(j) - lb(j)) + lb(j);
        end
    end
end

%%—— Lévy 飞行函数 ——%%
function z = levy(n, m, beta)
    num = gamma(1+beta)*sin(pi*beta/2);
    den = gamma((1+beta)/2)*beta*2^((beta-1)/2);
    sigma_u = (num/den)^(1/beta);
    u = sigma_u .* randn(n, m);
    v = randn(n, m);
    z = u ./ (abs(v).^(1/beta));
end
