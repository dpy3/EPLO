function X = initialization(N, dim, ub, lb)
    % 如果 ub 或 lb 是标量，将其扩展为 dim 大小的数组
    if length(ub) == 1
        ub = repmat(ub, 1, dim);
    end
    if length(lb) == 1
        lb = repmat(lb, 1, dim);
    end
    
    % 检查 ub 和 lb 的长度是否与 dim 匹配
    assert(length(ub) == dim, 'Upper bound (ub) length must match dimension (dim)');
    assert(length(lb) == dim, 'Lower bound (lb) length must match dimension (dim)');
    
    % 初始化种群位置
    X = rand(N, dim) .* (ub - lb) + lb;
end
