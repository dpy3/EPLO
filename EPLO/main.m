% main.m – CEC2022 基准下，多算法对比，兼容 EPLO 输出，添加收敛曲线
clc; clear; close all;

%% 参数设置
pop     = 30;    % 种群规模
T       = 500;   % 最大迭代次数
dim     = 10;    % 问题维度
n_runs  = 30;    % 重复运行次数
F_index = 12;     % CEC2022 测试函数编号（1–12）

%% 加载 CEC2022 测试函数
[lb, ub, dim, fobj] = Get_Functions_cec2022(F_index, dim);

%% 算法列表
algorithms = {'BKA','WOA','FOX','PLO','PLOA','EPLO','ALO','BA','GSA','HHO','MFO'};
numAlgos   = numel(algorithms);

%% 预分配
final_fitness      = nan(n_runs, numAlgos);
std_fitness       = nan(1, numAlgos);
mean_fitness      = nan(1, numAlgos);
convergence_runs  = nan(T, n_runs, numAlgos);

%% 多次运行
for j = 1:numAlgos
    algo = algorithms{j};
    fprintf('Running algorithm: %s\n', algo);
    for r = 1:n_runs
        try
            [o1, o2, o3] = feval(algo, pop, T, lb, ub, dim, fobj);
            if isscalar(o1)
                fitness = o1;
            elseif isvector(o2)
                fitness = o2(end);
            elseif isvector(o3)
                fitness = o3(end);
            else
                error('无法解析输出格式');
            end
            final_fitness(r, j) = fitness;
            if isvector(o3) && length(o3) == T
                convergence_runs(:, r, j) = o3;
            elseif isvector(o2) && length(o2) == T
                convergence_runs(:, r, j) = o2;
            else
                convergence_runs(:, r, j) = nan(T,1);
            end
        catch ME
            fprintf('  %s run %d failed: %s\n', algo, r, ME.message);
            final_fitness(r, j) = NaN;
            convergence_runs(:, r, j) = nan(T,1);
        end
    end
end

%% 统计 & 平移
mean_fitness = mean(final_fitness, 1, 'omitnan');
std_fitness  = std(final_fitness, 0, 1, 'omitnan');
min_mean = min(mean_fitness);
shift_val = max(0, -min_mean);
mean_fitness = mean_fitness + shift_val;

%% 打印 & 保存
fprintf('\n=== CEC2022 F%d (dim=%d) 对比实验结果 ===\n', F_index, dim);
fprintf('Shift applied: %.4e\n', shift_val);
fprintf('%-10s\tMean Fitness\tSTD\n', 'Algorithm');
for j = 1:numAlgos
    fprintf('%-10s\t%.4e\t%.4e\n', algorithms{j}, mean_fitness(j), std_fitness(j));
end
save('CEC2022_Results.mat', 'final_fitness', 'mean_fitness', 'std_fitness', 'algorithms', 'shift_val');
fprintf('\nResults saved to CEC2022_Results.mat\n');

%% 颜色设置
% 如果你装了 File Exchange 里的 distinguishable_colors 函数，可以用下面这行：
% colors = distinguishable_colors(numAlgos, {'w','k'}); 

% 否则用这个扩展颜色数组，确保有足够的颜色：
base_colors = [...
    0 0.4470 0.7410;  % blue
    0.8500 0.3250 0.0980; % orange
    0.9290 0.6940 0.1250; % yellow
    0.4940 0.1840 0.5560; % purple      
    0.3010 0.7450 0.9330; % cyan
    0.6350 0.0780 0.1840; % dark red
    0.25 0.25 0.25; % dark gray
    1 0 1; % magenta
    0 0.5 0; % dark green
    1 0 0; % red
    0.5 0.5 0.5; % gray
    0.8 0.4 0.2; % brown
    0.2 0.8 0.2; % lime green
    0.8 0.2 0.8; % pink
    0.2 0.2 0.8]; % dark blue

% 如果算法数量超过预定义颜色，使用循环方式
if numAlgos <= size(base_colors, 1)
    colors = base_colors(1:numAlgos, :);
else
    % 循环使用颜色
    color_indices = mod(0:numAlgos-1, size(base_colors, 1)) + 1;
    colors = base_colors(color_indices, :);
end

%% 绘制平均收敛曲线
figure('Name','CEC2022 Convergence Curves','NumberTitle','off'); hold on; grid on;
set(gcf, 'Color', 'w');   % 图窗背景白色
set(gca, 'Color', 'w');   % 坐标轴背景白色

for j = 1:numAlgos
    mean_curve = mean(squeeze(convergence_runs(:,:,j)), 2, 'omitnan');
    plot(1:T, mean_curve, 'LineWidth', 2.5, 'Color', colors(j,:));
end

xticks(0:100:T);
ylim_auto = ylim;
yticks(linspace(ylim_auto(1), ylim_auto(2), 6));

xlabel('Iteration','FontSize', 20);
ylabel('Fitness','FontSize', 20);
title(sprintf('F%d', F_index),'FontSize', 20);

hleg = legend(algorithms, 'Interpreter','none', 'Location','northeastoutside', 'FontSize', 20);
set(hleg, 'Box', 'on');

pbaspect([2 2 1])

saveas(gcf, sprintf('Convergence_F%d_dim%d.png', F_index, dim));
fprintf('Convergence curves saved to Convergence_F%d_dim%d.png\n', F_index, dim);
