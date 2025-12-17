function fitness = spring(x)
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    f = (x3+2)*x2*(x1^2);
    panaty_factor = 10e100;
    
    % 修正：确保 r 计算时没有维度不匹配问题
    m = 10;  % 假设 m 是 10，可以根据实际问题调整
    r = (0:m-1)' / max(m-1, 1);  % 确保 r 为列向量
    
    g1 = 1 - ((x2^3) * x3) / (71785 * (x1^4));
    g2 = (4 * (x2^2) - x1 * x2) / (12566 * (x2 * (x1^3) - (x1^4))) + 1 / (5108 * (x1^2)) - 1;
    g3 = 1 - (140.45 * x1) / ((x2^2) * x3);
    g4 = ((x1 + x2) / 1.5) - 1;
    
    panaty_1 = panaty_factor * (max(0, g1))^2;
    panaty_2 = panaty_factor * (max(0, g2))^2;
    panaty_3 = panaty_factor * (max(0, g3))^2;
    panaty_4 = panaty_factor * (max(0, g4))^2;
    
    fitness = f + panaty_1 + panaty_2 + panaty_3 + panaty_4;
end
