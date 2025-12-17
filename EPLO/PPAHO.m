function [fMin, bestX, Convergence_curve, Stats] = PPAHO(pop, M, c, d, dim, fobj, opts)
% PPAHO (Hybrid_PPAHO_OCSSA_v2 内核)
% Improved hybrid optimizer (PPAHO + OCSSA + JADE/SHADE ideas)
% Usage:
%   [fMin, bestX, Convergence_curve] = PPAHO(pop, M, c, d, dim, fobj, opts)
% Optional opts fields:
%   .seed (default 1)
%   .verbose (default true)
%   .FEs_limit (optional)
%   .memetic_budget (default 80)
%   .memetic_prob (default 0.15)
%   .pop_anneal (true/false default true) -- enable population annealing
%   .anneal_start (fraction of M when anneal begins, default 0.4)
%   .anneal_final_frac (final fraction of pop to keep, default 0.25)
%
% Outputs:
%   fMin - best objective
%   bestX - best solution (1xd)
%   Convergence_curve - 1 x iter_count
%   Stats - structure with counters (operator acceptance rates, FEs used)

if nargin < 7, opts = struct(); end
if ~isfield(opts,'seed'), opts.seed = 1; end
if ~isfield(opts,'verbose'), opts.verbose = false; end
if ~isfield(opts,'memetic_budget'), opts.memetic_budget = 120; end
if ~isfield(opts,'memetic_prob'), opts.memetic_prob = 0.15; end
if ~isfield(opts,'anneal_start'), opts.anneal_start = 0.35; end
if ~isfield(opts,'anneal_final_frac'), opts.anneal_final_frac = 0.22; end
if ~isfield(opts,'pop_anneal'), opts.pop_anneal = true; end

rng(opts.seed);

% bounds normalization
if isscalar(c)
    lb = c * ones(1,dim);
else
    lb = c(:)';
end
if isscalar(d)
    ub = d * ones(1,dim);
else
    ub = d(:)';
end

% safety
pop = max(6, round(pop));
M = max(10, round(M));

% hyperparams (tuneable)
levy_beta = 1.5;
patience = max(12, round(0.06 * M));
base_P_percent = 0.28;
elite_frac = 0.08; % top fraction for p-best selection

% SHADE-like memory (H)
H = 8;
M_F = 0.6 * ones(1,H);
M_CR = 0.9 * ones(1,H);
h_idx = 1;

% bookkeeping and stats
FEs = 0;
Convergence_curve = zeros(1, M);
Stats = struct();
Stats.accept = struct('serve',0,'pbestDE',0,'spin',0,'swipe',0,'memetic',0,'others',0);
Stats.attempts = Stats.accept;
% 外部档案 A（用于 JADE/SHADE 的变异差分项），初始化为空
A = zeros(0, dim);

% -------- initialization: median-of-three (chaos + opposition + LHS) ----------
seeds = rand(pop, dim);
for k=1:6, seeds = 4.*seeds.*(1-seeds); end
Xc = repmat(lb, pop, 1) + seeds .* repmat((ub-lb), pop, 1);  % chaotic
Xo = repmat(lb, pop, 1) + (1 - seeds) .* repmat((ub-lb), pop, 1); % opposition
% LHS jitter (toolbox-free fallback)
if exist('lhsdesign','file') == 2
    Xl = repmat(lb,pop,1) + lhsdesign(pop, dim, 'iterations',1) .* repmat((ub-lb), pop,1);
else
    Xl = repmat(lb,pop,1) + local_lhs(pop, dim) .* repmat((ub-lb), pop,1);
end
% pick the median among Xc, Xo, Xl per-individual to avoid too-low start
X = zeros(pop, dim);
fit = inf(pop,1);
for i=1:pop
    cand1 = Bounds(Xc(i,:), lb, ub); f1 = fobj(cand1);
    cand2 = Bounds(Xo(i,:), lb, ub); f2 = fobj(cand2);
    cand3 = Bounds(Xl(i,:), lb, ub); f3 = fobj(cand3);
    FEs = FEs + 3;
    [fs, ord] = sort([f1, f2, f3]); %#ok<ASGLU>
    switch ord(2)
        case 1, X(i,:) = cand1; fit(i) = f1;
        case 2, X(i,:) = cand2; fit(i) = f2;
        case 3, X(i,:) = cand3; fit(i) = f3;
    end
end

% personal bests
pX = X; pFit = fit;

% global best
[fMin, bi] = min(pFit);
bestX = pX(bi,:);

% elite archive size
elite_k = max(2, round(elite_frac * pop));
[~, idx] = sort(pFit);
elite_idx = idx(1:elite_k);
elite_X = pX(elite_idx,:); %#ok<NASGU>

% population annealing schedule
if opts.pop_anneal
    anneal_iter = max(1, round(opts.anneal_start * M));
    final_frac = min(max(opts.anneal_final_frac, 0.05), 0.5);
else
    anneal_iter = Inf;
    final_frac = 1.0;
end

no_improve_count = 0;

% main loop
for it = 1:M
    phase = it / M; % 0..1, early->late
    % 每次迭代重置 SHADE 成功记忆缓存
    S_Fs = [];
    S_CRs = [];
    W_s = [];
    % adaptive diversity metric
    div = population_diversity(X, lb, ub);
    % update P_percent: more producers when diversity low
    P_percent = min(0.55, max(0.08, base_P_percent + 0.28 * (1 - tanh(5*div))));
    pNum = max(2, round(pop * P_percent));
    
    % dynamic scale decays
    global_scale = (1 - it/M);
    
    % compute sorted indices by pFit (personal best)
    [~, sortIndex] = sort(pFit);
    prod_idx = sortIndex(1:pNum);
    other_idx = sortIndex(pNum+1:end);
    
    % ==== PRODUCER UPDATES: use p-best DE (JADE-style) and OCSSA selection mixed ====
    % We'll try p-best/1 mutation: v = x + F*(pbest - x) + F*(xr1 - xr2)
    % sample F,CR via SHADE-like memory
    idx_h = randi(H);
    muF = M_F(idx_h); muCR = M_CR(idx_h);
    F_sample = min(1.2, max(0.2, cauchy_rand_positive(muF, 0.08))) * (0.6 + 0.6*phase);
    % 替代 normrnd(muCR,0.1) 以避免统计工具箱依赖
    CR_sample = min(1, max(0, muCR + 0.08*randn));
    % prioritize pbest-DE early, reduce later
    prob_pbest = 0.5 - 0.2*phase; % early less pbest-DE to slow quick drops
    
    for ii = prod_idx'
        % attempt either OCSSA-style imitation or pbest-DE with probabilities
        if rand >= prob_pbest
            % OCSSA imitation of selected good fish
            FP = pFit(prod_idx);
            XP = pX(prod_idx,:);
            % find local better among producers
            local_index = find(FP < pFit(ii));
            if isempty(local_index)
                sel_pos = XP(1,:);
            else
                if rand < 0.6
                    sel_pos = XP(1,:);
                else
                    sel_pos = XP(local_index(randi(length(local_index))),:);
                end
            end
            I = randi([1,2]);
            scale = (0.08 + 0.30*rand) * (0.5 + 0.5*global_scale) * (0.6 + 0.4*phase);
            cand = X(ii,:) + (rand(1,dim)) .* (sel_pos - I*X(ii,:)) .* scale;
            % evaluate
            f_cand = fobj(cand); FEs = FEs + 1;
            Stats.attempts.serve = Stats.attempts.serve + 1;
            if f_cand < fit(ii)
                X(ii,:) = Bounds(cand, lb, ub);
                fit(ii) = f_cand;
                Stats.accept.serve = Stats.accept.serve + 1;
            end
        else
            % p-best DE mutation（带档案 A 和动态 pbest 收缩）
            % choose pbest randomly from top pbest_size
            pbest_size = max(2, round( (0.20 - 0.15*(it/M)) * pop )); % 从20%线性收缩至约5%
            pbest_set = sortIndex(1:pbest_size);
            pbest_idx = pbest_set(randi(length(pbest_set)));
            pbest = X(pbest_idx,:);
            % pick r1,r2 distinct from ii，并与档案 A 混合
            ids = setdiff(1:pop, ii);
            r = ids(randperm(length(ids),2));
            xr1 = X(r(1),:);
            xr2 = X(r(2),:);
            if ~isempty(A) && rand < 0.5
                xr2 = A(randi(size(A,1)),:);
            end
            v = X(ii,:) + F_sample * (pbest - X(ii,:)) + F_sample * (xr1 - xr2);
            % crossover
            jrand = randi(dim);
            u = X(ii,:);
            for j = 1:dim
                if rand <= CR_sample || j == jrand
                    u(j) = v(j);
                end
            end
            u = Bounds(u, lb, ub);
            f_u = fobj(u); FEs = FEs + 1;
            Stats.attempts.pbestDE = Stats.attempts.pbestDE + 1;
            if f_u < fit(ii)
                x_old = X(ii,:); % 记录被替换的个体进入档案
                X(ii,:) = u; fit(ii) = f_u;
                Stats.accept.pbestDE = Stats.accept.pbestDE + 1;
                % record success F and CR for memory update
                S_Fs( end+1 ) = F_sample; %#ok<SAGROW>
                S_CRs( end+1 ) = CR_sample; %#ok<SAGROW>
                W_s( end+1 ) = (fit(ii) - f_u); %#ok<SAGROW>
                % 更新档案 A（FIFO）
                A = [A; x_old];
                if size(A,1) > pop, A(1,:) = []; end
            end
        end
    end
    
    % ==== OTHER UPDATES: Cauchy around best, Levy jumps when diversity high ====
    [~, bestII] = min(fit);
    bestXX = X(bestII,:);
    cntOther = length(other_idx);
    if cntOther > 0
        rr = local_cauchy(cntOther,1);
        for k = 1:cntOther
            i = other_idx(k);
            rmove = rand;
            if rmove < 0.55
                % Cauchy around best scaled by distance
                scale = 0.25 * (0.5 + 0.5*global_scale) + 0.02;
                cand = bestXX + rr(k) * scale .* (bestXX - X(i,:));
                Stats.attempts.spin = Stats.attempts.spin + 1;
            elseif rmove < (0.55 + 0.12 * (div > 0.12)) % Levy only when diversity relatively high
                L = levy(1,dim,levy_beta);
                scale = 0.45 * global_scale * (0.6 + 0.4*phase); % smaller early
                cand = X(i,:) + scale * L .* (ub - lb);
                Stats.attempts.swipe = Stats.attempts.swipe + 1;
            else
                % small directed move toward personal best
                cand = pX(i,:) + 0.03 * randn(1,dim) .* (ub - lb) * (0.5 + 0.5*global_scale) * (0.6 + 0.4*phase);
                Stats.attempts.others = Stats.attempts.others + 1;
            end
            cand = Bounds(cand, lb, ub);
            f_cand = fobj(cand); FEs = FEs + 1;
            if f_cand < fit(i)
                X(i,:) = cand; fit(i) = f_cand;
                if rmove < 0.55
                    Stats.accept.spin = Stats.accept.spin + 1;
                elseif rmove < (0.55 + 0.18 * (div > 0.08))
                    Stats.accept.swipe = Stats.accept.swipe + 1;
                else
                    Stats.accept.others = Stats.accept.others + 1;
                end
            end
        end
    end
    
    % ==== Random recombine block (OCSSA-inspired b-block) - focused on a sample ====
    cperm = randperm(pop);
    bcount = min(20, pop);
    bset = cperm(1:bcount);
    for idxb = bset
        % choose behavior similar to OCSSA
        if pFit(idxb) > fMin
            % move near best with gaussian
            cand = bestX + 0.28 * randn(1,dim) .* abs(pX(idxb,:) - bestX);
        else
            denom = abs(pFit(idxb) - max(pFit)) + 1e-12; % stabilized denominator
            % 使用当前最佳个体 bestXX 进行引导
            cand = pX(idxb,:) + (2*rand(1,dim)-1) .* abs(pX(idxb,:) - bestXX) ./ denom;
        end
        cand = Bounds(cand, lb, ub);
        f_cand = fobj(cand); FEs = FEs + 1;
        if f_cand < fit(idxb)
            X(idxb,:) = cand; fit(idxb) = f_cand;
            Stats.accept.others = Stats.accept.others + 1;
        end
        Stats.attempts.others = Stats.attempts.others + 1;
    end
    
    % update personal bests
    for i = 1:pop
        if fit(i) < pFit(i)
            pFit(i) = fit(i);
            pX(i,:) = X(i,:);
        end
    end
    
    % update global best (elitist)
    [currMin, idxMin] = min(pFit);
    if currMin < fMin - 1e-12
        fMin = currMin; bestX = pX(idxMin,:);
        no_improve_count = 0;
    else
        no_improve_count = no_improve_count + 1;
    end
    
    % update elite archive
    [~, idxP] = sort(pFit);
    elite_k = max(2, round(elite_frac * pop));
    elite_idx = idxP(1:elite_k);
    elite_X = pX(elite_idx,:); %#ok<NASGU>
    % elite_F 未被使用，移除以避免静态检查提示
    
    % ==== memetic: apply to top few individuals with higher prob in later iterations ====
    mem_prob = opts.memetic_prob * (0.5 + phase); % gentler increase
    topk_mem = max(1, round(0.02 * pop)); % 2% top individuals
    for kk = 1:topk_mem
        if phase > 0.35 && rand < mem_prob && FEs < (getFEsLimit(opts))
            i_mem = idxP(kk); % top individuals by personal best
            optsf = optimset('Display','off','MaxFunEvals', min(opts.memetic_budget, 200), 'MaxIter', min(opts.memetic_budget,200));
            try
                [xloc, floc, ~, output] = fminsearch_wrap(@(y) fobj(reshape(y,1,[])), X(i_mem,:), optsf, lb, ub);
                fe_used = output.funcCount;
                FEs = FEs + fe_used;
                xloc = Bounds(xloc, lb, ub);
                if floc < fit(i_mem)
                    X(i_mem,:) = xloc; fit(i_mem) = floc;
                    Stats.accept.memetic = Stats.accept.memetic + 1;
                end
            catch
                % ignore failures
            end
            Stats.attempts.memetic = Stats.attempts.memetic + 1;
        end
    end
    
    % ==== SHADE-like update for M_F and M_CR if successes recorded ====
    if exist('S_Fs','var') && ~isempty(S_Fs)
        wsum = sum(W_s);
        if wsum == 0
            W = ones(1,length(W_s)) / length(W_s);
        else
            W = W_s / wsum;
        end
        % Lehmer mean for F
        newF = sum(W .* (S_Fs.^2)) / sum(W .* S_Fs);
        newCR = sum(W .* S_CRs);
        M_F(h_idx) = newF;
        M_CR(h_idx) = newCR;
        h_idx = h_idx + 1; if h_idx > H, h_idx = 1; end
        clear S_Fs S_CRs W_s
    end
    
    % ==== population annealing (reduce population late) ====
    if opts.pop_anneal && it >= anneal_iter
        frac_done = (it - anneal_iter) / (M - anneal_iter + 1);
        target_frac = 1 - frac_done * (1 - final_frac);
        target_pop = max(4, round(target_frac * pop));
        % if we need to shrink active pop, remove worst individuals (keep pX and pFit but mark inactive)
        if target_pop < pop
            % keep top target_pop by pFit
            [~, idx_keep] = sort(pFit);
            keep_idx = idx_keep(1:target_pop);
            remove_idx = setdiff(1:pop, keep_idx);
            % duplicate best ones slightly (to keep population size same) or just shrink active set
            % here we shrink active set: mark removed ones as 'frozen' but still keep for record
            % simpler: set their positions near bestX with tiny noise so they remain productive
            for r = remove_idx
                X(r,:) = bestX + 1e-3 * randn(1,dim) .* (ub - lb);
                fit(r) = fobj(X(r,:));
                FEs = FEs + 1;
            end
            % we keep pop same but now many are set near best (effectively focusing)
        end
    end

    % === 周期性/停滞复苏：对最差个体执行 LHS + 反对学习 (OBL) 重采样 ===
    if mod(it, max(10, round(0.15*M))) == 0 || (no_improve_count > round(0.6*patience))
        [~, worst_order] = sort(pFit, 'descend');
        q = max(1, round(0.10 * pop));
        widx = worst_order(1:q);
        % LHS 采样 q 个候选
        jit = local_lhs(q, dim);
        Xlhs = repmat(lb,q,1) + jit .* repmat((ub-lb), q,1);
        % 对应的反对解
        Xobl = repmat(lb,q,1) + repmat((ub-lb), q,1) - Xlhs;
        for kk = 1:q
            fx1 = fobj(Bounds(Xlhs(kk,:), lb, ub)); FEs = FEs + 1;
            fx2 = fobj(Bounds(Xobl(kk,:), lb, ub)); FEs = FEs + 1;
            if fx1 <= fx2
                candx = Xlhs(kk,:); fxc = fx1;
            else
                candx = Xobl(kk,:); fxc = fx2;
            end
            if fxc < fit(widx(kk))
                X(widx(kk),:) = candx;
                fit(widx(kk)) = fxc;
            end
        end
    end
    
    % ==== strong local search on stagnation threshold ====
    if no_improve_count >= patience
        % perform stronger local search from bestX with larger budget
        strong_budget = min(600, 10 * opts.memetic_budget);
        optsf = optimset('Display','off','MaxFunEvals', strong_budget, 'MaxIter', strong_budget);
        try
            [xloc, floc, ~, output] = fminsearch_wrap(@(y) fobj(reshape(y,1,[])), bestX, optsf, lb, ub);
            fe_used = output.funcCount;
            FEs = FEs + fe_used;
            xloc = Bounds(xloc, lb, ub);
            if floc < fMin
                fMin = floc; bestX = xloc;
            end
            % reduce no_improve_count so we don't immediately retrigger
            no_improve_count = 0;
            if opts.verbose, fprintf('Strong local search applied at iter %d, new best %.6e\n', it, fMin); end
        catch
            % ignore
        end
    end
    
    % trim/record convergence
    Convergence_curve(it) = fMin;
    if opts.verbose && mod(it, max(1, round(M/10))) == 0
        fprintf('Iter %d/%d  best=%.6e  mean=%.6e  div=%.3e  pNum=%d  FEs=%d\n', it, M, fMin, mean(fit), div, pNum, FEs);
    end
    
    % check FEs limit
    if isfield(opts,'FEs_limit') && ~isempty(opts.FEs_limit) && FEs >= opts.FEs_limit
        if opts.verbose, fprintf('FEs limit reached at iter %d\n', it); end
        break;
    end
end

% ensure Convergence_curve has exact length M (pad if early break)
if numel(Convergence_curve) < M
    last = Convergence_curve(find(Convergence_curve~=0,1,'last'));
    if isempty(last), last = fMin; end
    Convergence_curve(end+1:M) = last;
end

% output stats summary
Stats.FEs = FEs;
Stats.accept = Stats.accept;
Stats.attempts = Stats.attempts;

if opts.verbose, fprintf('Finished. Best = %.6e by FEs=%d\n', fMin, FEs); end
end

%% ---------------- helper functions ----------------
function s = Bounds(s_in, Lb, Ub)
s = s_in;
I = s < Lb; s(I) = Lb(I);
J = s > Ub; s(J) = Ub(J);
end

function r = local_cauchy(m, n)
Z1 = randn(m,n); Z2 = randn(m,n); Z2(Z2==0) = eps; r = Z1 ./ Z2;
end

function v = levy(n,m,beta)
if nargin < 3, beta = 1.5; end
num = gamma(1+beta)*sin(pi*beta/2);
den = gamma((1+beta)/2)*beta*2^((beta-1)/2);
sigma_u = (num/den)^(1/beta);
u = randn(n,m) * sigma_u;
v = u ./ (abs(randn(n,m)).^(1/beta));
end

function r = cauchy_rand_positive(mu, gamma)
% sample Cauchy centered at mu, reflect to positive
u = rand - 0.5;
r = mu + gamma * tan(pi*u);
if r <= 0, r = abs(r) + 1e-6; end
end

function divv = population_diversity(Xmat, lb, ub)
Nn = size(Xmat,1);
if Nn <= 1, divv = 0; return; end
mu = mean(Xmat,1);
divv = sqrt(sum(sum((Xmat - mu).^2,2)) / Nn);
rng_scale = mean(ub - lb);
if rng_scale > 0, divv = divv / rng_scale; end
end

function [x,f,exitflag,output] = fminsearch_wrap(fun, x0, options, LB, UB)
proj_fun = @(y) fun(Bounds(reshape(y,1,[]), LB, UB));
[x,f,exitflag,output] = fminsearch(proj_fun, x0, options);
end

function lim = getFEsLimit(opts)
if isfield(opts,'FEs_limit') && ~isempty(opts.FEs_limit)
    lim = opts.FEs_limit;
else
    lim = Inf;
end
end

% 本地拉丁超立方体采样（无需统计工具箱），返回 n×d 的 [0,1] 样本
function X = local_lhs(n, d)
X = zeros(n, d);
for j = 1:d
    strata = (rand(n,1) + (0:n-1)') / n; % 分层均匀覆盖 (0,1)
    X(:, j) = strata(randperm(n));       % 每维独立打乱
end
end
