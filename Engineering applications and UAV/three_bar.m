function fitness = three_bar(x)
    l = 100; % 杆长度
    P = 2;   % 外力
    q = 2;   % 最大允许应力
    x1 = x(1);
    x2 = x(2);

    % 目标函数
    f = l * (2 * sqrt(2) * x1 + x2);

    % 惩罚因子
    penalty_factor = 10e100;

    % 约束条件
    g1 = P * (sqrt(2) * x1 + x2) / (sqrt(2) * x1^2 + 2 * x1 * x2) - q;
    g2 = P * x2 / (sqrt(2) * x1^2 + 2 * x1 * x2) - q;
    g3 = P / (sqrt(2) * x2 + x1) - q;

    % 惩罚项
    penalty_g1 = penalty_factor * (max(0, g1))^2;
    penalty_g2 = penalty_factor * (max(0, g2))^2;
    penalty_g3 = penalty_factor * (max(0, g3))^2;

    % 总适应度
    fitness = f + penalty_g1 + penalty_g2 + penalty_g3;
end
