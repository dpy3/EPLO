function [Best_pos, Bestscore, Convergence_curve] = EPLO(N, MaxFEs, lb, ub, dim, fhd)
    % EPLO: 并行子群 + 并行交流策略 + 精英池 + 多策略微调
    %
    % 输入:
    %   N, MaxFEs, lb, ub, dim, fhd 与原 PLO 相同
    % 输出:
    %   Best_pos, Bestscore, Convergence_curve

    %%—— 参数设置 —————————————————————————
    groups = 4;                    % 子群数量
    Np     = floor(N/groups);     % 每子群粒子数
    wMax   = 0.9; wMin = 0.2;
    c1Max  = 2.5; c1Min = 0.5;
    c2Max  = 2.5; c2Min = 0.5;
    elite_pool_size = 5;          % 精英池容量
    elite_sigma = 0.01 * (ub - lb);
    % 并行交流参数
    migration_period = 20;        % 迁移周期（代）
    migrate_count   = 1;          % 每组迁移粒子数

    %%—— 初始化 —————————————————————————
    % 全局精英池
    elite_pool = repmat(struct('pos',[],'fit',inf),1,elite_pool_size);
    % 子群结构
    init = lb + (ub-lb).*rand(N,dim);
    for g = 1:groups
        idx = (g-1)*Np + (1:Np);
        group(g).pos        = init(idx,:);
        group(g).vel        = zeros(Np,dim);
        group(g).fitness    = inf(Np,1);
        group(g).pBest      = group(g).pos;
        group(g).pBestScore = inf(Np,1);
        group(g).gBest      = zeros(1,dim);
        group(g).gBestScore = inf;
    end

    Convergence_curve = zeros(1,MaxFEs);
    global_best_score  = inf;
    global_best_pos    = zeros(1,dim);

    %%—— 主循环 —————————————————————————
    for t = 1:MaxFEs
        tau = t/MaxFEs;
        w  = wMax - (wMax - wMin) * tau^1.5;
        c1 = c1Max - (c1Max - c1Min) * tau;
        c2 = c2Min + (c2Max - c2Min) * tau;
        pOpp = 0.5 * (1 - tau);

        % —— 并行子群更新 ——
        for g = 1:groups
            for i = 1:Np
                % 速度、位置更新
                group(g).vel(i,:) = w*group(g).vel(i,:) ...
                    + c1*rand(1,dim).*(group(g).pBest(i,:) - group(g).pos(i,:)) ...
                    + c2*rand(1,dim).*(group(g).gBest      - group(g).pos(i,:));
                group(g).pos(i,:) = group(g).pos(i,:) + group(g).vel(i,:);
                group(g).pos(i,:) = max(min(group(g).pos(i,:), ub), lb);

                % Opposition 学习
                if rand < pOpp
                    opp = ub + lb - group(g).pos(i,:);
                    opp = max(min(opp, ub), lb);
                    if fhd(opp) < fhd(group(g).pos(i,:))
                        group(g).pos(i,:) = opp;
                    end
                end

                % 评估 & 更新 pBest
                fi = fhd(group(g).pos(i,:));
                group(g).fitness(i) = fi;
                if fi < group(g).pBestScore(i)
                    group(g).pBest(i,:)    = group(g).pos(i,:);
                    group(g).pBestScore(i) = fi;
                end
            end

            % 更新子群 gBest
            [fg, idx] = min(group(g).pBestScore);
            if fg < group(g).gBestScore
                group(g).gBestScore = fg;
                group(g).gBest      = group(g).pBest(idx,:);
            end
        end

        % —— 并行交流（迁移）——
        if mod(t, migration_period) == 0
            for g = 1:groups
                next_g = mod(g, groups) + 1;
                % 将当前 g 组的 gBest 迁移到 next_g 组的最差粒子
                % 找到 next_g 组的最差 pBest
                [~, worst_idx] = max(group(next_g).pBestScore);
                group(next_g).pos(worst_idx,:)       = group(g).gBest;
                group(next_g).pBest(worst_idx,:)     = group(g).gBest;
                group(next_g).pBestScore(worst_idx)  = group(g).gBestScore;
            end
        end

        % —— 精英池 & 全局 gBest 更新 ——
        for g = 1:groups
            cand_pos = group(g).gBest;
            cand_fit = group(g).gBestScore;
            [~, worst] = max([elite_pool.fit]);
            if cand_fit < elite_pool(worst).fit
                elite_pool(worst).pos = cand_pos;
                elite_pool(worst).fit = cand_fit;
            end
            if cand_fit < global_best_score
                global_best_score = cand_fit;
                global_best_pos   = cand_pos;
            end
        end

        % —— 中后期多策略微调 ——
        if t>0.4*MaxFEs && mod(t,10)==0
            delta = levy(1,dim,1.5).*(ub-lb);
            cand = global_best_pos + delta;
            cand = max(min(cand,ub),lb);
            fc = fhd(cand);
            if fc < global_best_score
                global_best_score = fc;
                global_best_pos   = cand;
            end
        end
        if t>0.6*MaxFEs
            base = fhd(global_best_pos);
            eps  = 1e-6; grad = zeros(1,dim);
            for j=1:dim
                tmp=global_best_pos; tmp(j)=tmp(j)+eps;
                grad(j)=(fhd(tmp)-base)/eps;
            end
            if norm(grad)>0
                dir = -grad/norm(grad);
                cand = global_best_pos + 0.05*(ub-lb).*dir;
                cand = max(min(cand,ub),lb);
                fc = fhd(cand);
                if fc<global_best_score
                    global_best_score = fc;
                    global_best_pos   = cand;
                end
            end
        end
        if mod(t,50)==0
            noise = randn(1,dim).*elite_sigma;
            cand = global_best_pos + noise;
            cand = max(min(cand,ub),lb);
            fc = fhd(cand);
            if fc<global_best_score
                global_best_score = fc;
                global_best_pos   = cand;
            end
        end

        Convergence_curve(t) = global_best_score;
        if mod(t,100)==0
            fprintf('Iter %3d/%3d, Best = %.4e\n', t, MaxFEs, global_best_score);
        end
    end

    Best_pos  = global_best_pos;
    Bestscore = global_best_score;
end

%% Levy 飞行函数
function z = levy(n, m, beta)
    num = gamma(1+beta)*sin(pi*beta/2);
    den = gamma((1+beta)/2)*beta*2^((beta-1)/2);
    sigma = (num/den)^(1/beta);
    u = randn(n,m)*sigma;
    v = randn(n,m);
    z = u ./ abs(v).^(1/beta);
end