% main.m – CEC2022 基准下，多算法对比，兼容 EPLO 输出，箱线图展示最终适应度分布（boxplot 强制着色），图像为正方形
clc; clear; close all;

%% 参数设置
pop     = 30;    % 种群规模
T       = 500;   % 最大迭代次数
dim     = 10;    % 问题维度
n_runs  = 30;    % 重复运行次数
F_index = 1;     % CEC2022 测试函数编号（1–12）

%% 加载 CEC2022 测试函数
[lb, ub, dim, fobj] = Get_Functions_cec2022(F_index, dim);

%% 算法列表
algorithms = {'BKA','WOA','FOX','PLO','EPLO','ALO','BA','GSA','HHO','MFO'};
numAlgos   = numel(algorithms);

%% 预分配
final_fitness      = nan(n_runs, numAlgos);
std_fitness       = nan(1, numAlgos);
mean_fitness      = nan(1, numAlgos);
convergence_runs  = nan(T, n_runs, numAlgos);

%% 多次运行（调用各算法）
for j = 1:numAlgos
    algo = algorithms{j};
    fprintf('Running algorithm: %s\n', algo);
    for r = 1:n_runs
        try
            [o1, o2, o3] = feval(algo, pop, T, lb, ub, dim, fobj);
            % 尝试解析输出：优先取标量输出，否则取向量末值
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
            % 尝试保存收敛曲线（若有）
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

%% 统计 & 平移（确保绘图时无负值，便于箱线图显示）
mask = ~isnan(final_fitness);
counts = sum(mask, 1);
tmp = final_fitness; tmp(~mask) = 0;
mean_fitness = sum(tmp, 1) ./ counts; mean_fitness(counts == 0) = NaN;
diffs = tmp - repmat(mean_fitness, size(final_fitness,1), 1); diffs(~mask) = 0;
variance = sum(diffs.^2, 1) ./ max(counts - 1, 1); variance(counts <= 1) = NaN;
std_fitness = sqrt(variance);
min_mean = min(mean_fitness);
shift_val = max(0, -min_mean);   % 若 mean 中存在负值则平移到非负域
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

%% 颜色设置（与原脚本一致）
colors = [...
    0 0.4470 0.7410;  % blue
    0.8500 0.3250 0.0980; % orange
    0.9290 0.6940 0.1250; % yellow
    0.4940 0.1840 0.5560; % purple      
    0.3010 0.7450 0.9330; % cyan
    0.6350 0.0780 0.1840; % dark red
    0.25 0.25 0.25; % dark gray
    1 0 1; % magenta
    0 0.5 0; % dark green
    1 0 0]; % red

colors = colors(1:numAlgos,:); % 选取前numAlgos个颜色

%% 绘制箱线图（优先使用 boxchart；否则使用 boxplot 并强制着色）
% 创建正方形图窗（像素单位），例如 900x900
figSize = 900;
figure('Name','CEC2022 Boxplots of Final Fitness','NumberTitle','off', 'Units', 'pixels', 'Position', [100, 100, figSize, figSize]);
set(gcf, 'Color', 'w');   % 图窗背景白色
ax = axes;
hold(ax, 'on');
grid(ax, 'on');

% 检查 MATLAB 是否支持 boxchart（R2019b+）
has_boxchart = exist('boxchart','file') || exist('boxchart','builtin');

if has_boxchart
    % 使用 boxchart 单独绘制每个算法的箱线并着色
    for j = 1:numAlgos
        vals = final_fitness(:, j);
        vals = vals(~isnan(vals));
        if isempty(vals)
            continue;
        end
        vals = vals + shift_val;
        x = j * ones(size(vals));
        h = boxchart(x, vals, 'BoxWidth', 0.6);
        try
            h.BoxFaceColor = colors(j,:);
            h.LineWidth = 1.2;
            h.MarkerStyle = 'none';
        catch
            % 兼容不同版本的属性名差异
        end
        jitter = (rand(size(vals)) - 0.5) * 0.25;
        scatter(j + jitter, vals, 18, 'MarkerEdgeColor', colors(j,:), 'MarkerFaceColor', 'none', 'LineWidth', 0.6);
    end
    xlim([0.5, numAlgos + 0.5]);
    xticks(1:numAlgos);
    xticklabels(algorithms);
else
    % 使用自定义箱线图实现替代 boxplot
    % 准备数据向量与分组变量
    data_vec = final_fitness(:);
    group = repmat(1:numAlgos, n_runs, 1);
    group = group(:);
    mask = ~isnan(data_vec);
    data_vec = data_vec(mask) + shift_val;
    group = group(mask);

    % 自定义箱线图绘制
    for j = 1:numAlgos
        data = data_vec(group == j);
        if isempty(data)
            continue;
        end
        
        % 计算箱线图统计量
        q1 = prctile(data, 25);
        q2 = prctile(data, 50); % 中位数
        q3 = prctile(data, 75);
        iqr = q3 - q1;
        
        % 计算须的范围
        lower_whisker = max(min(data), q1 - 1.5 * iqr);
        upper_whisker = min(max(data), q3 + 1.5 * iqr);
        
        % 找出离群点
        outliers = data(data < lower_whisker | data > upper_whisker);
        
        % 绘制箱体
        box_width = 0.6;
        x_pos = j;
        col = colors(j, :);
        
        % 绘制箱体矩形（带填充）
        rectangle('Position', [x_pos - box_width/2, q1, box_width, q3-q1], ...
                 'EdgeColor', col, 'FaceColor', col, 'FaceAlpha', 0.35, 'LineWidth', 1.2);
        
        % 绘制中位数线
        line([x_pos - box_width/2, x_pos + box_width/2], [q2, q2], ...
             'Color', col, 'LineWidth', 2);
        
        % 绘制须线
        line([x_pos, x_pos], [q3, upper_whisker], 'Color', col, 'LineWidth', 1.2);
        line([x_pos, x_pos], [q1, lower_whisker], 'Color', col, 'LineWidth', 1.2);
        
        % 绘制须端的横线
        line([x_pos - box_width/4, x_pos + box_width/4], [upper_whisker, upper_whisker], ...
             'Color', col, 'LineWidth', 1.2);
        line([x_pos - box_width/4, x_pos + box_width/4], [lower_whisker, lower_whisker], ...
             'Color', col, 'LineWidth', 1.2);
        
        % 绘制离群点
        if ~isempty(outliers)
            scatter(repmat(x_pos, length(outliers), 1), outliers, 36, '+', ...
                   'MarkerEdgeColor', col, 'LineWidth', 1.5);
        end
        
        % 添加散点抖动效果
        jitter = (rand(size(data)) - 0.5) * 0.25;
        scatter(x_pos + jitter, data, 18, 'MarkerEdgeColor', col, 'MarkerFaceColor', 'none', 'LineWidth', 0.6);
    end
    
    xlim([0.5, numAlgos + 0.5]);
    xticks(1:numAlgos);
    xticklabels(algorithms);
end

% 通用美化
ylabel('Fitness (shifted)','FontSize', 14);
xlabel('Algorithm','FontSize', 14);
title(sprintf('F%d', F_index),'FontSize', 14);
set(gca, 'FontSize', 12);
xtickangle(45);

% 强制正方形纵横比
pbaspect([1 1 1]);

% 保存图像（PNG，使用 saveas；在新版 MATLAB 可用 exportgraphics 提高质量）
outname = sprintf('Boxplot_FinalFitness_F%d_dim%d.png', F_index, dim);
try
    % 优先使用 exportgraphics（更高质量）
    exportgraphics(gcf, outname, 'Resolution', 300);
catch
    saveas(gcf, outname);
end
fprintf('Boxplot saved to %s\n', outname);
