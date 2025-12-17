function fitness = welded_beam(x)
    % 输入变量
    h = x(1); % 焊接厚度
    l = x(2); % 焊接长度
    t = x(3); % 垂直梁厚度
    b = x(4); % 垂直梁宽度

    % 常量
    P = 6000;   % 载荷
    L = 14;     % 水平梁长度
    E = 30e6;   % 弹性模量
    G = 12e6;   % 剪切模量
    tau_max = 13600; % 最大剪应力
    sigma_max = 30000; % 最大正应力
    delta_max = 0.25;  % 最大允许位移

    % 计算目标函数（材料成本）
    f = 1.10471 * h^2 * l + 0.04811 * t * b * (14 + l);

    % 计算约束条件
    tau = sqrt((P / (sqrt(2) * h * l))^2 + ...
               ((6 * P * L) / (h * l^2))^2 + ...
               (P * L / (h * l))^2); % 剪应力

    sigma = 504000 / (t^2 * b); % 正应力
    delta = (6 * P * L^3) / (E * t * b^3); % 位移

    % 定义约束
    g1 = tau - tau_max;         % 剪应力约束
    g2 = sigma - sigma_max;     % 正应力约束
    g3 = delta - delta_max;     % 位移约束
    g4 = 0.125 - h;             % 焊接厚度下限
    g5 = t - b;                 % 梁厚度和宽度关系

    % 惩罚因子
    penalty_factor = 1e10;
    penalty = penalty_factor * sum(max(0, [g1, g2, g3, g4, g5]).^2);

    % 目标函数值
    fitness = f + penalty;
end
