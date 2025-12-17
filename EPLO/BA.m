function [Best_Fitness_BA, Best_Pos_BA, Convergence_curve_BA] = BA(pop, T, lb, ub, dim, fobj)
    % 初始化计时器
    tic;

    % 设置BA参数
    FES = 0;
    t = 1; 
    maxT = T; % 最大迭代次数
    sizep = pop; % 种群大小

    % 确保 lb 和 ub 是向量，并且长度与 dim 相同
    if length(lb) == 1
        lb = lb * ones(1, dim);
    end
    if length(ub) == 1
        ub = ub * ones(1, dim);
    end

    A = 0.6 * ones(sizep, 1);    % 响度 (不变或者减小)
    r = zeros(sizep, 1);         % 脉冲率 (不变或增加)
    r0 = 0.7;
    Af = 0.9;
    Rf = 0.9;
    Qmin = 0;                    % 最小频率
    Qmax = 1;                    % 最大频率

    % 初始化种群及其速度、频率
    Lb = lb;
    Ub = ub;
    pop = Lb + (Ub - Lb) .* rand(sizep, dim); % 种群初始化
    popv = zeros(sizep, dim);   % 速度
    Q = zeros(sizep, 1);        % 频率

    pfitness = inf(sizep, 1);   % 初始化适应度值为无穷大
    for i = 1:sizep
        pfitness(i) = fobj(pop(i, :)); % 计算初始适应度值
        FES = FES + 1;
    end
    [Best_Fitness_BA, bestID] = min(pfitness);
    Best_Pos_BA = pop(bestID, :);

    % 初始化收敛曲线
    Convergence_curve_BA = inf(1, maxT);

    while t <= maxT
        for i = 1:sizep
            Q(i) = Qmin + (Qmax - Qmin) * rand();
            popv(i, :) = popv(i, :) + (pop(i, :) - Best_Pos_BA) * Q(i);
            Stemp = pop(i, :) + popv(i, :);

            % 边界检查
            Stemp = max(min(Stemp, ub), lb);

            % 脉冲率
            if rand > r(i)
                Stemp = Best_Pos_BA + 0.001 * randn(1, dim);
            end
            
            fitTemp = fobj(Stemp);
            FES = FES + 1;

            % 更新解和适应度值
            if (fitTemp <= pfitness(i)) && (rand < A(i))
                pop(i, :) = Stemp;
                pfitness(i) = fitTemp;
                A(i) = Af * A(i);
                r(i) = r0 * (1 - exp(-Rf * t));
            end

            % 更新全局最优解
            if fitTemp <= Best_Fitness_BA
                Best_Fitness_BA = fitTemp;
                Best_Pos_BA = Stemp;
            end
        end

        % 更新收敛曲线
        Convergence_curve_BA(t) = Best_Fitness_BA;

        t = t + 1;
    end

    % 结束计时
    toc;
end