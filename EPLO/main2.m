function main()
    clear;
    clc;
    close all;

    %% 参数设置
    pop = 30;         % 种群大小
    T = 500;          % 最大迭代次数
    dim = 30;         % 问题维度
    n_runs = 30;      % 每个算法运行次数
    F_name = 'F27';   % 测试函数名称（可根据需要修改）
    
    % 算法列表（可自行增减）
    algorithms = {'BKA','WOA','SCA','FOX','PLO','EPLO','ALO','BA','GSA','HHO','MFO'};
    numAlgos = length(algorithms);
    
    %% 加载测试函数
    [lb, ub, ~, fobj] = CEC2017(F_name);
    
    %% 仅存储最终适应值用于绘制箱线图
    final_fitness = zeros(n_runs, numAlgos);

    %% 针对每个算法进行多次独立运行
    for j = 1:numAlgos
        fprintf('Running algorithm: %s\n', algorithms{j});
        for r = 1:n_runs
            try
                [~, best_fit, ~] = feval(algorithms{j}, pop, T, lb, ub, dim, fobj);
                % best_fit(end) 视为该算法在本次运行结束后的最终适应值
                final_fitness(r,j) = best_fit(end);
            catch ME
                fprintf('Algorithm %s failed on run %d: %s\n', algorithms{j}, r, ME.message);
                final_fitness(r,j) = NaN;
            end
        end
    end

    %% 绘制箱线图（使用自定义实现）
    figure('Units','normalized','OuterPosition',[0 0 0.75 0.65],'Color','w');
    
    % 自定义箱线图实现
    hold on; grid on;
    
    % 计算每个算法的统计量
    for j = 1:numAlgos
        data = final_fitness(:, j);
        data = data(~isnan(data)); % 移除 NaN 值
        
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
        box_width = 0.5;
        x_pos = j;
        
        % 绘制箱体矩形
        rectangle('Position', [x_pos - box_width/2, q1, box_width, q3-q1], ...
                 'EdgeColor', 'k', 'FaceColor', 'none', 'LineWidth', 1);
        
        % 绘制中位数线
        line([x_pos - box_width/2, x_pos + box_width/2], [q2, q2], ...
             'Color', 'k', 'LineWidth', 2);
        
        % 绘制须线
        line([x_pos, x_pos], [q3, upper_whisker], 'Color', 'k', 'LineWidth', 1);
        line([x_pos, x_pos], [q1, lower_whisker], 'Color', 'k', 'LineWidth', 1);
        
        % 绘制须端的横线
        line([x_pos - box_width/4, x_pos + box_width/4], [upper_whisker, upper_whisker], ...
             'Color', 'k', 'LineWidth', 1);
        line([x_pos - box_width/4, x_pos + box_width/4], [lower_whisker, lower_whisker], ...
             'Color', 'k', 'LineWidth', 1);
        
        % 绘制离群点
        if ~isempty(outliers)
            scatter(repmat(x_pos, length(outliers), 1), outliers, 16, 'o', ...
                   'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none');
        end
        
        % 绘制均值（红色菱形）
        mean_val = mean(data, 'omitnan');
        plot(x_pos, mean_val, 'rd', 'MarkerSize', 6, 'LineWidth', 1.2);
    end

    % 对数坐标
    set(gca, 'YScale', 'log');
    
    % 设置 X 轴标签
    set(gca, 'XTick', 1:numAlgos, 'XTickLabel', algorithms);
    xlim([0.5, numAlgos + 0.5]);

    % 添加标题和坐标轴标签
    title(['Best fitness distributions for ', F_name, ...
           ' (dim=', num2str(dim), ', ', num2str(n_runs), ' runs)'], ...
          'FontSize',13, 'FontWeight','bold');
    ylabel('Best fitness distributions','FontWeight','bold');

    % 显示箱线图外观
    box on;

    %% 尝试加载并显示结果图像（若存在）
    try
        img = imread('result_image.png');
        figure;
        imshow(img);
        title('Result Image');
    catch ME
        warning('Unable to load image file: %s', ME.message);
    end
end
