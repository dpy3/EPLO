function [optimal_electrode_pos, min_potential_energy, energy_convergence] = EIMO(ion_population, max_migration_steps, lower_boundary, upper_boundary, solution_dimension, objective_function)
% ========================================================================
% Electrolytic Ion Migration Optimization (EIMO) Algorithm
% 基于硫酸铜(CuSO4)电解质溶液中离子迁移现象的元启发式优化算法
% 
% 算法原理：模拟Cu2+阳离子和SO4^2-阴离子在CuSO4·5H2O电解质溶液中的迁移行为
% 物理系统：硫酸铜电解池 - 阴极反应：Cu2+ + 2e- → Cu，阳极反应：2H2O → O2 + 4H+ + 4e-
% Cu2+离子迁移率：5.56×10^-8 m²/(V·s)，SO4^2-离子迁移率：8.29×10^-8 m²/(V·s)
%
% 输入参数：
%   ion_population      - 离子群体数量 (对应原始种群规模N)
%   max_migration_steps - 最大迁移步数 (对应原始最大迭代次数MaxFEs)
%   lower_boundary      - 溶液边界下限 (对应原始下界lb)
%   upper_boundary      - 溶液边界上限 (对应原始上界ub)
%   solution_dimension  - 溶液空间维度 (对应原始维度dim)
%   objective_function  - 电势能函数 (对应原始目标函数fhd)
%
% 输出参数：
%   optimal_electrode_pos - 最优电极位置 (对应原始Best_pos)
%   min_potential_energy  - 最小电势能 (对应原始Bestscore)
%   energy_convergence    - 能量收敛曲线 (对应原始Convergence_curve)
% ========================================================================

    %% 离子群体初始化阶段
    % 在溶液空间中随机分布离子初始位置
    ion_positions = lower_boundary + (upper_boundary - lower_boundary) .* rand(ion_population, solution_dimension);
    
    % 初始化离子迁移速度（基于布朗运动）
    migration_velocity = zeros(ion_population, solution_dimension);
    
    % 初始化电势能
    potential_energy = inf(ion_population, 1);
    
    % 离子个体历史最优位置（局部电势能最小点）
    individual_best_position = ion_positions;
    individual_min_energy = inf(ion_population, 1);
    
    % 全局最优电极位置（系统电势能最小点）
    global_min_energy = inf;
    global_optimal_electrode = zeros(1, solution_dimension);

    % 能量收敛监测
    energy_convergence = zeros(1, max_migration_steps);

    %% 电化学参数设置 (CuSO4电解系统)
    % 基于硫酸铜五水合物的实验数据
    max_mobility_coefficient = 0.85;  % 最大离子迁移率 (稀CuSO4溶液，25°C)
    min_mobility_coefficient = 0.35;  % 最小离子迁移率 (浓缩溶液)
    
    % CuSO4特异性电场强度系数
    individual_field_strength = 1.8;  % Cu2+局部电场强度 (二价阳离子)
    global_field_strength = 2.2;      % 应用电势场强度 (Cu沉积增强)
    
    % CuSO4电化学常数
    faraday_constant = 96485;          % 法拉第常数 (C/mol)
    cu_charge = 2;                     % Cu2+电荷数
    so4_charge = -2;                   % SO4^2-电荷数
    standard_potential = 0.34;         % 标准电极电势 (V vs SHE)

    %% 离子迁移主循环
    for migration_step = 1:max_migration_steps
        % 动态迁移率计算（CuSO4浓度效应模型）
        % 模拟离子强度增加和阴极附近Cu2+耗尽效应
        current_mobility = max_mobility_coefficient - ...
                          (max_mobility_coefficient - min_mobility_coefficient) * ...
                          migration_step / max_migration_steps;
        
        % CuSO4特异性迁移率修正（Stokes-Einstein关系）
        % 考虑水合Cu2+离子尺寸和溶液粘度
        viscosity_factor = 1 + 0.1 * (migration_step / max_migration_steps);
        current_mobility = current_mobility / viscosity_factor;

        for ion_index = 1:ion_population
            %% 离子迁移动力学方程
            % 基于Einstein-Smoluchowski方程的离子运动模型
            % v(t+1) = μ·v(t) + D₁·∇E_individual + D₂·∇E_global
            
            % Cu2+个体电场梯度力（向局部阴极位点的吸引）
            individual_gradient_force = individual_field_strength * rand(1, solution_dimension) .* ...
                                      (individual_best_position(ion_index, :) - ion_positions(ion_index, :));
            
            % Cu2+全局电场梯度力（向主阴极的迁移）
            % 由Cu2+的二价性质增强 (电荷 = +2)
            global_gradient_force = global_field_strength * cu_charge/2 * rand(1, solution_dimension) .* ...
                                  (global_optimal_electrode - ion_positions(ion_index, :));
            
            % 添加浓度梯度力（Fick定律）
            % 模拟电极表面附近Cu2+耗尽效应
            concentration_gradient = 0.1 * randn(1, solution_dimension);
            diffusion_force = concentration_gradient;
            
            % 更新Cu2+离子迁移速度（基于Nernst-Planck方程）
            migration_velocity(ion_index, :) = current_mobility * migration_velocity(ion_index, :) + ...
                                             individual_gradient_force + global_gradient_force + diffusion_force;
            
            % 应用CuSO4特异性速度约束
            % 基于Cu2+扩散系数限制 (7.33×10^-10 m²/s)
            max_velocity = 0.5; % 归一化最大速度
            migration_velocity(ion_index, :) = max(-max_velocity, min(max_velocity, migration_velocity(ion_index, :)));
            
            % 更新离子位置
            ion_positions(ion_index, :) = ion_positions(ion_index, :) + migration_velocity(ion_index, :);

            %% 溶液边界约束处理
            % 离子不能超出溶液容器边界
            ion_positions(ion_index, :) = max(min(ion_positions(ion_index, :), upper_boundary), lower_boundary);

            %% 电势能计算（CuSO4系统）
            % 包含Cu2+还原电势和浓度效应
            potential_energy(ion_index) = objective_function(ion_positions(ion_index, :));
            
            % 添加CuSO4特异性能量修正
            % 考虑Cu2+水合能和电极动力学
            position_energy = sum(ion_positions(ion_index, :).^2) * 1e-6; % 归一化位置能
            potential_energy(ion_index) = potential_energy(ion_index) + position_energy;

            %% 个体最优位置更新
            if potential_energy(ion_index) < individual_min_energy(ion_index)
                individual_best_position(ion_index, :) = ion_positions(ion_index, :);
                individual_min_energy(ion_index) = potential_energy(ion_index);
            end
        end

        %% 全局最优电极位置更新
        [current_global_min, optimal_ion_index] = min(individual_min_energy);
        if current_global_min < global_min_energy
            global_min_energy = current_global_min;
            global_optimal_electrode = individual_best_position(optimal_ion_index, :);
        end

        %% 记录能量收敛过程
        energy_convergence(migration_step) = global_min_energy;

        %% 迁移过程监测
        if mod(migration_step, 10) == 0
            fprintf('迁移步数 %d: 最小电势能 = %.6e\n', migration_step, global_min_energy);
        end
    end

    %% 返回优化结果
    optimal_electrode_pos = global_optimal_electrode;
    min_potential_energy = global_min_energy;
end