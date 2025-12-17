function run_for_engineering()
    clc;
    clear;
    close all;

    %% 添加算法路径
    % addpath('C:/Your_Algorithm_Path');

    %% 参数设置
    type = 9; % 例如：8 表示悬臂梁设计问题（根据 Engineering_Problems 中的定义）
    [lb_raw, ub_raw, dim, fobj] = Engineering_Problems(type);
    
    % 边界标准化处理：确保 lb 和 ub 为行向量
    if iscolumn(lb_raw)
        lb = lb_raw';
    else
        lb = lb_raw;
    end
    if iscolumn(ub_raw)
        ub = ub_raw';
    else
        ub = ub_raw;
    end
    % 如果边界向量长度大于1，则取第一个值作为统一约束（根据实际情况调整）
    if length(lb) > 1 || length(ub) > 1
        warning('使用第一个边界值作为统一约束');
        lb = lb(1);
        ub = ub(1);
    end

    nPop = 50;             % 种群数
    Max_iter = 500;        % 最大迭代次数
    n_runs = 30;           % 每个算法运行次数

    %% 算法列表（工程应用问题使用的算法）
    algorithms = {'BKA','WOA','SCA','FOX','PLO','EPLO','ALO','BA','GSA','HHO','MFO'};
    numAlgos = length(algorithms);

    % 预定义颜色，每个算法固定一种颜色（可自行调整）
    algorithm_colors = [...
        0, 0, 1;         % BKA - 蓝色
        0.85, 0.10, 0.30; % WOA - 紫红色
        0.50, 0, 0.50;    % SCA - 紫色
        0.90, 0.20, 0.70;  % FOX - 粉色
        0.95, 0.90, 0.25;  % PLO - 灰黄色
        0.70, 0.35, 0.00;  % EPLO - 棕色
        0.40, 0.40, 0.40;  % ALO - 灰色
        0.60, 0.80, 0.20;  % BA - 绿色
        0, 0, 0;         % GSA - 黑色
        0, 0.80, 0.80;    % HHO - 青色
        0.50, 0.10, 0.80]; % MFO - 淡紫色

    %% 结果存储变量
    % final_fitness: 存储每个算法的 n_runs 次运行的最终适应值（行：运行次数，列：算法）
    final_fitness = zeros(n_runs, numAlgos);
    % all_convergence: cell 数组，每个元素为 n_runs x Max_iter 的矩阵，用于存储每个算法所有运行的收敛曲线
    all_convergence = cell(numAlgos, 1);
    for j = 1:numAlgos
        all_convergence{j} = zeros(n_runs, Max_iter);
    end

    %% 主优化循环（仅对单个工程问题进行多次运行）
    fprintf('工程问题运行（type = %d）...\n', type);
    for run = 1:n_runs
        fprintf('Run %d/%d...\n', run, n_runs);
        for alg_idx = 1:numAlgos
            alg_name = algorithms{alg_idx};
            try
                % 调用算法函数，假设返回值为 [best_sol, best_fit, conv_curve]
                [~, best_fit, conv_curve] = feval(alg_name, nPop, Max_iter, lb, ub, dim, fobj);
                
                % 标准化收敛曲线长度：如果不足 Max_iter，则填充最后一个值；超过则截断
                if length(conv_curve) < Max_iter
                    conv_curve(end+1:Max_iter) = conv_curve(end);
                elseif length(conv_curve) > Max_iter
                    conv_curve = conv_curve(1:Max_iter);
                end
                
                final_fitness(run, alg_idx) = best_fit(end);
                all_convergence{alg_idx}(run, :) = conv_curve;
            catch ME
                fprintf('算法 %s 运行失败, run = %d: %s\n', alg_name, run, ME.message);
                final_fitness(run, alg_idx) = NaN;
                all_convergence{alg_idx}(run, :) = NaN(1, Max_iter);
            end
        end
    end

    %% 计算统计数据（最终适应值的均值和标准差）
    summaryTable = zeros(numAlgos, 2);  % 列1: Mean, 列2: Std
    for j = 1:numAlgos
        validIdx = ~isnan(final_fitness(:, j));
        summaryTable(j, 1) = mean(final_fitness(validIdx, j));
        summaryTable(j, 2) = std(final_fitness(validIdx, j));
    end

    %% 输出统计结果（类似 Table 9 样式）
    fprintf('\n=== 统计结果  %d次运行) ===\n', n_runs);
    fprintf('算法\t\t均值 (AVG)\t\t标准差 (STD)\n');
    for j = 1:numAlgos
        fprintf('%-6s\t%.4e\t\t%.4e\n', algorithms{j}, summaryTable(j, 1), summaryTable(j, 2));
    end

    %% 计算每个算法的平均收敛曲线
    avg_convergence = zeros(numAlgos, Max_iter);
    for j = 1:numAlgos
        valid_curves = all_convergence{j}(~any(isnan(all_convergence{j}), 2), :);
        if isempty(valid_curves)
            avg_convergence(j, :) = NaN;
        else
            avg_convergence(j, :) = mean(valid_curves, 1);
        end
    end

       %% 绘制所有算法的平均收敛曲线（同一图中）
    figure('Units', 'normalized', 'OuterPosition', [0 0 0.6 0.6], 'Color', 'w'); % 改为正方形比例
    hold on;
    grid on;
    set(gca, 'YScale', 'log'); % 对数坐标显示
    for j = 1:numAlgos
        semilogy(1:Max_iter, avg_convergence(j, :), ...
            'Color', algorithm_colors(j, :), ...
            'LineWidth', 3, ...            % 曲线加粗
            'DisplayName', algorithms{j});
    end
    axis square; % 坐标轴正方
    title(sprintf('平均收敛曲线 (%d次运行)', n_runs), 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('迭代次数', 'FontSize', 12);
    ylabel('最优适应度值', 'FontSize', 12);
    legend('Location', 'eastoutside', 'FontSize', 9, 'NumColumns', 2);
    xlim([1, Max_iter]);

    
    %% 保存结果到文件
    save('optimization_stats.mat', 'final_fitness', 'summaryTable', 'avg_convergence', 'algorithms');
    fprintf('统计结果已保存到 optimization_stats.mat.\n');
    
    %% 显示原始图像部分（保留不变）
    try
        img = imread('result_image.png');
        figure;
        imshow(img);
        title('Result Image');
    catch ME
        warning('无法加载图像文件：%s', ME.message);
    end
end
