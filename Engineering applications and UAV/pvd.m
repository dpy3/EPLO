function fitness = pvd(x)
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    x4 = x(4);
    f = 0.6224*x1*x3*x4 + 1.7781*x2*x3^2 + 3.1661*x1^2*x4 + 19.84*x1^2*x3;
    panaty_factor = 10e100; % 按需修改
    %
    g1 = -x1 + 0.0193*x3;
    panalty_1 = panaty_factor*(max(0,g1))^2;
    g2 = -x2 + 0.00954*x3;
    panalty_2 = panaty_factor*(max(0,g2))^2;
    g3 = -pi*x3^2*x4 - (4/3)*pi*x3^3 + 1296000;
    panalty_3 = panaty_factor*(max(0,g3))^2;
    g4 = x4 - 240;
    panalty_4 = panaty_factor*(max(0,g4))^2;
    fitness = f + panalty_1 + panalty_2 + panalty_3 + panalty_4;
end
