function [lb,ub,dim,fobj] = Engineering_Problems(type)
% ENGINEERING_PROBLEMS 返回指定 type 的上下界、维度和目标函数句柄
% 用法:
%   [lb,ub,dim,fobj] = Engineering_Problems(type)

switch type
    case 1 % Tension/compression spring design problem
        fobj = @spring;
        lb = [0.05 0.25  2];
        ub = [2    1.3   15];
        dim = length(lb);
    case 2 % Pressure vessel design problem
        fobj = @pvd;
        lb =[0 0 10 10];
        ub = [99 99 200 200];
        dim = length(lb);
    case 3 % Three-bar truss design problem
        fobj = @three_bar;
        lb = [0 0];
        ub = [1 1];
        dim = length(lb);
    case 4 % Welded beam design problem
        fobj = @welded_beam;
        lb = [0.1 0.1 0.1 0.1];
        ub = [2 10 10 2];
        dim = length(lb);
    case 5 % Speed reducer design problem
        fobj = @speed_reducer;
        lb = [2.6 0.7 17 7.3 7.3 2.9 5];
        ub = [3.6 0.8 28 8.3 8.3 3.9 5.5];
        dim = length(lb);
    case 6 % Gear train design problem
        fobj = @gear_train;
        lb = [12 12 12 12];
        ub= [60 60 60 60];
        dim = length(lb);
    case 7 % Rolling element bearing design
        fobj = @rolling_element_bearing;
        D=160; d=90;
        lb=[0.5*(D+d) 0.15*(D-d) 4 0.515 0.515 0.4 0.6 0.3 0.02 0.6];
        ub=[0.6*(D+d) 0.45*(D-d) 50 0.6 0.6 0.5 0.7 0.4 0.1 0.85];
        dim=length(lb);
    case 8 % Cantilever beam design problem
        fobj = @cantilever_beam;
        lb = [0.01,0.01,0.01,0.01,0.01];
        ub= [100,100,100,100,100];
        dim = length(lb);
    case 9 % Multiple disk clutch brake design problem
        fobj = @Multiple_disk;
        lb=[60,90,1,600,2];
        ub=[80,110,3,1000,9];
        dim=length(lb);
    case 10 % Step-cone pulley problem
        fobj = @Step_cone_pulley;
        lb=[0,0,0,0,0];
        ub=[60,60,90,90,90];
        dim=length(lb);
    case 11 % Planetary Gear Train Design
        fobj = @Planetary_Gear_Train;
        lb=[17,14,14,17,14,48,1,1,1];
        ub=[96,54,51,46,51,124,6,6,3];
        dim=length(lb);
    case 12 % Robot gripper design optimization problem
        fobj = @Robot_Gripper;
        lb=[10,10,100,0,10,100,1];
        ub=[150,150,200,50,150,300,3.14];
        dim=length(lb);
    otherwise
        error('Unknown type: %d', type);
end

end

% ----------------------------
% 以下为各个目标函数定义（与你提供的函数保持一致）
% 请注意：这些函数与原始代码保持一致，包含惩罚项的实现
% ----------------------------

function fitness = spring(x)
    % clamp
    x = min(max(x, [0.05 0.25 2]), [2 1.3 15]);
    x1 = x(1); x2 = x(2); x3 = x(3);
    f  = (x3 + 2) * x2 * x1^2;
    panaty_factor = 1e6;
    g1 = 1 - (x2^3 * x3) / (71785 * x1^4);
    g2 = (4 * x2^2 - x1 * x2) / (12566 * (x2 * x1^3 - x1^4)) + 1/(5108 * x1^2) - 1;
    g3 = 1 - (140.45 * x1) / (x2^2 * x3);
    g4 = (x1 + x2)/1.5 - 1;
    penalties = panaty_factor * sum(max(0, [g1 g2 g3 g4]).^2);
    fitness = f + penalties;
end

function fitness = pvd(x)
    x1= x(1); x2 = x(2); x3 = x(3); x4 = x(4);
    f = 0.6224*x1*x3*x4 + 1.7781*x2*x3^2+3.1661*x1^2*x4+19.84*x1^2*x3;
    panaty_factor = 1e10;
    g1 = -x1+0.0193*x3; panalty_1 = panaty_factor*(max(0,g1))^2;
    g2 = -x2+0.00954*x3; panalty_2 = panaty_factor*(max(0,g2))^2;
    g3 = -pi*x3^2*x4 - (4/3)*pi*x3^3 + 1296000; panalty_3 = panaty_factor*(max(0,g3))^2;
    g4 = x4 - 240; panalty_4 = panaty_factor*(max(0,g4))^2;
    fitness = f + panalty_1 + panalty_2 + panalty_3 + panalty_4;
end

function fitness = three_bar(x)
    l = 100; P = 2; q = 2;
    x1= x(1); x2 = x(2);
    f = l*(2*sqrt(2)*x1+x2);
    panaty_factor = 1e10;
    g1 = P*(sqrt(2)*x1+x2)/(sqrt(2)*x1^2+2*x1*x2)-q; penalty_g1 = panaty_factor*(max(0,g1))^2;
    g2 = P*(x2)/(sqrt(2)*x1^2+2*x1*x2)-q; penalty_g2 = panaty_factor*(max(0,g2))^2;
    g3 = P/(sqrt(2)*x2+x1)-q; penalty_g3 = panaty_factor*(max(0,g3))^2;
    fitness = f+penalty_g1+penalty_g2+penalty_g3;
end

function fitness = welded_beam(x)
    P = 6000; L=14; E=30e6; G = 12e6; tmax=13600; sigma_max=30000; deta_max=0.25;
    x1= x(1); x2 = x(2); x3 = x(3); x4 = x(4);
    M=P*(L+0.5*x2);
    r1 = (x2^2)/4; r2 = ((x1+x3)/2)^2; R = (r1+r2)^0.5;
    j1=sqrt(2)*x1*x2; j2 = (x2^2)/12; j3 = ((x1+x3)/2)^2; J=2*(j1*(j2+j3));
    sigma_x=6*P*L/(x4*x3^2);
    deta_x = 4*P*L^3/((E*x4)*(x3^3));
    p1 = (4.013*E*((x3^2)*(x4^6)/36)^0.5)/(L^2);
    p2 = (x3/(2*L))*(E/(4*G))^0.5; Pc = p1*(1-p2);
    t_1 =  P/(sqrt(2*x1*x2));
    t_2 = M*R/J;
    t=((t_1)^2 + 2*t_1*t_2*(x2/(2*R))+(t_2)^2)^0.5;
    f = 1.10471*(x1^2)*x2+0.04811*x3*x4*(14+x2);
    panaty_factor = 1e10;
    g1 = t-tmax; penalty_g1 = panaty_factor*(max(0,g1))^2;
    g2 = sigma_x-sigma_max; penalty_g2 = panaty_factor*(max(0,g2))^2;
    g3 = deta_x - deta_max; penalty_g3 = panaty_factor*(max(0,g3))^2;
    g4 = x1-x4; penalty_g4 = panaty_factor*(max(0,g4))^2;
    g5 = P - Pc; penalty_g5 = panaty_factor*(max(0,g5))^2;
    g6 = 0.125-x1; penalty_g6 = panaty_factor*(max(0,g6))^2;
    g7 =1.10471*(x1^2)*x2+0.04811*x3*x4*(14+x2)-5; penalty_g7 = panaty_factor*(max(0,g7))^2;
    fitness = f+penalty_g1+penalty_g2+penalty_g3+penalty_g4+penalty_g5 +penalty_g6+penalty_g7;
end

function fitness = speed_reducer(x)
    x1= x(1); x2 = x(2); x3 = x(3); x4 = x(4); x5 = x(5); x6 = x(6); x7 = x(7);
    f = 0.7854*x1*x2^2*(3.3333*x3^2 + 14.9334*x3 - 43.0934) -...
        1.508*x1*(x6^2 + x7^2) + 7.4777*(x6^3+x7^3) + 0.7854*(x4*x6^2 + x5*x7^2);
    panaty_factor = 1e10;
    g1 = (27/(x1*x2^2*x3))-1 ; penalty_g1 = panaty_factor*(max(0,g1))^2;
    g2 = (397.5/(x1*x2^2*x3^2)) - 1; penalty_g2 = panaty_factor*(max(0,g2))^2;
    g3 = (1.93*x4^3/(x2*x3*x6^4)) - 1; penalty_g3 = panaty_factor*(max(0,g3))^2;
    g4 = (1.93*x5^3/(x2*x3*x7^4)) - 1; penalty_g4 = panaty_factor*(max(0,g4))^2;
    g5 = (1/(110*x6^3))*(((745*x4/(x2*x3))^2 + 16.9*1e6)^0.5)-1; penalty_g5 = panaty_factor*(max(0,g5))^2;
    g6 = (1/(85*x7^3))*(((745*x5/(x2*x3))^2 + 157.5*1e6)^0.5)-1; penalty_g6 = panaty_factor*(max(0,g6))^2;
    g7 = (x2*x3/40) - 1; penalty_g7 = panaty_factor*(max(0,g7))^2;
    g8 = (5*x2/x1) - 1; penalty_g8 = panaty_factor*(max(0,g8))^2;
    g9 = (x1/(12*x2)) - 1; penalty_g9 = panaty_factor*(max(0,g9))^2;
    g10 = ((1.5*x6+1.9)/(x4)) - 1; penalty_g10 = panaty_factor*(max(0,g10))^2;
    g11 = ((1.1*x7+1.9)/(x5)) - 1; penalty_g11 = panaty_factor*(max(0,g11))^2;
    fitness = f+penalty_g1 + penalty_g2 + penalty_g3 + penalty_g4 + penalty_g5 + penalty_g6 + penalty_g7 +...
        penalty_g8 + penalty_g9 + penalty_g10 + penalty_g11;
end

function fitness = gear_train(x)
    x = round(x);
    fitness=(1/6.931-(x(2)*x(3)/(x(1)*x(4))))^2;
end

function fitness = rolling_element_bearing(x)
    panalty_factor = 1e10;
    D=160;d=90;Bw=30;
    Dm=x(1); Db=x(2); Z=x(3); fi=x(4); f0=x(5); KDmin=x(6); KDmax=x(7);
    ep = x(8); ee=x(9); xi=x(10);
    Z=round(Z);
    T=D-d-2*Db;
    phio=2*pi-acos(((((D-d)/2)-3*(T/4))^2+(D/2-T/4-Db)^2-(d/2+T/4)^2)...
        /(2*((D-d)/2-3*(T/4))*(D/2-T/4-Db)));
    g(1)=1+phio/(2*asin(Db/Dm))-Z;
    g(2)=-2*Db+KDmin*(D-d);
    g(3)= -KDmax*(D-d)+2*Db;
    g(4)=xi*Bw-Db;
    g(5)=-Dm+0.5*(D+d);
    g(6)=-(0.5+ee)*(D+d)+Dm;
    g(7)= -0.5*(D-Dm-Db)+ep*Db;
    g(8)=0.515-fi;
    g(9)=0.515-f0;
    penalty=panalty_factor*sum(g(g>0).^2);
    gama=Db/Dm;
    fc=37.91*((1+(1.04*((1-gama/1+gama)^1.72)*((fi*(2*f0-1)/f0*...
        (2*fi-1))^0.41))^(10/3))^-0.3)*((gama^0.3*(1-gama)^1.39)/...
        (1+gama)^(1/3))*(2*fi/(2*fi-1))^0.41;
    if Db<=25.4
        f=-fc*Z^(2/3)*Db^1.8;
    else
        f=-3.647*fc*Z^(2/3)*Db^1.4;
    end
    fitness=f+penalty;
end

function fitness=cantilever_beam(x)
    panalty_factor = 1e10;
    g(1)=61/x(1)^3+37/x(2)^3+19/x(3)^3+7/x(4)^3+1/x(5)^3-1;
    penalty=panalty_factor*sum(g(g>0).^2);
    fitness=0.0624*sum(x)+penalty;
end

function fitness=Multiple_disk(x)
    panalty_factor = 1e10;
    x = round(x);
    Mf = 3; Ms = 40; Iz = 55; n = 250; Tmax = 15; s = 1.5; delta = 0.5;
    Vsrmax = 10; rho = 0.0000078; pmax = 1; mu = 0.5; Lmax = 30; delR = 20;
    Mh = 2/3*mu*x(4)*x(5)*(x(2)^3-x(1)^3)/(x(2)^2-x(1)^2);
    Prz = x(4)/(pi*(x(2)^2-x(1)^2));
    Vsr = (2*pi*n/90)*(x(2)^3-x(1)^3)/(x(2)^2-x(1)^2);
    T   = (Iz*pi*n/30)/(Mh+Mf);
    g(1) = -x(2)+x(1)+delR;
    g(2) = (x(5)+1)*(x(3)+delta)-Lmax;
    g(3) = Prz-pmax;
    g(4) = Prz*Vsr-pmax*Vsrmax;
    g(5) = Vsr-Vsrmax;
    g(6) = T-Tmax;
    g(7) = s*Ms-Mh;
    g(8) = -T;
    penalty=panalty_factor*sum(g(g>0).^2);
    f = pi*(x(2)^2-x(1)^2)*x(3)*(x(5)+1)*rho;
    fitness=f+penalty;
end

function fitness=Step_cone_pulley(x)
    panalty_factor = 1e10;
    d1 = x(1)*1e-3; d2 = x(2)*1e-3; d3 = x(3)*1e-3; d4 = x(4)*1e-3; w = x(5)*1e-3;
    N = 350; N1 = 750; N2 = 450; N3 = 250; N4 = 150;
    rho = 7200; a = 3; mu = 0.35; s = 1.75*1e6; t = 8*1e-3;
    C1 = pi*d1/2*(1+N1/N)+(N1/N-1)^2*d1^2/(4*a)+2*a;
    C2 = pi*d2/2*(1+N2/N)+(N2/N-1)^2*d2^2/(4*a)+2*a;
    C3 = pi*d3/2*(1+N3/N)+(N3/N-1)^2*d3^2/(4*a)+2*a;
    C4 = pi*d4/2*(1+N4/N)+(N4/N-1)^2*d4^2/(4*a)+2*a;
    R1 = exp(mu*(pi-2*asin((N1/N-1)*d1/(2*a))));
    R2 = exp(mu*(pi-2*asin((N2/N-1)*d2/(2*a))));
    R3 = exp(mu*(pi-2*asin((N3/N-1)*d3/(2*a))));
    R4 = exp(mu*(pi-2*asin((N4/N-1)*d4/(2*a))));
    P1 = s*t*w*(1-exp(-mu*(pi-2*asin((N1/N-1)*d1/(2*a)))))*pi*d1*N1/60;
    P2 = s*t*w*(1-exp(-mu*(pi-2*asin((N2/N-1)*d2/(2*a)))))*pi*d2*N2/60;
    P3 = s*t*w*(1-exp(-mu*(pi-2*asin((N3/N-1)*d3/(2*a)))))*pi*d3*N3/60;
    P4 = s*t*w*(1-exp(-mu*(pi-2*asin((N4/N-1)*d4/(2*a)))))*pi*d4*N4/60;
    g(1) = -R1+2; g(2) = -R2+2; g(3) = -R3+2; g(4) = -R4+2;
    g(5) = -P1+(0.75*745.6998); g(6) = -P2+(0.75*745.6998);
    g(7) = -P3+(0.75*745.6998); g(8) = -P4+(0.75*745.6998);
    h(1) = C1-C2; h(2) = C1-C3; h(3) = C1-C4;
    panalty=panalty_factor*(sum(g(g>0).^2) + sum(h(abs(h)>0).^2));
    f = rho*w*pi/4*(d1^2*(1+(N1/N)^2)+d2^2*(1+(N2/N)^2)+d3^2*(1+(N3/N)^2)+d4^2*(1+(N4/N)^2));
    fitness=f+panalty;
end

function fitness = Planetary_Gear_Train(x)
    panalty_factor = 1e20;
    x = round(x);
    x(7) = max(1, min(6, x(7))); x(8) = max(1, min(6, x(8))); x(9) = max(1, min(3, x(9)));
    P_id = [3, 4, 5];
    m_id = [1.75, 2, 2.25, 2.5, 2.75, 3.0];
    N1 = x(1); N2 = x(2); N3 = x(3); N4 = x(4); N5 = x(5); N6 = x(6);
    m1 = m_id(x(7)); m2 = m_id(x(8)); p = P_id(x(9));
    i1 = N6 / N4; i01 = 3.11;
    i2 = (N6 * (N1*N3 + N2*N4)) / (N1*N3*(N6 + N4)); i02 = 1.84;
    iR = -(N2 * N6) / (N1 * N3); i0R = -3.11;
    f = max([abs(i1 - i01), abs(i2 - i02), abs(iR - i0R)]);
    Dmax = 220; delta22 = 0.5; delta33 = 0.5; delta55 = 0.5; delta35 = 0.5; delta34 = 0.5; delta56 = 0.5;
    numerator = (N6 - N3)^2 + (N4 + N5)^2 - (N3 + N5)^2;
    denominator = 2 * (N6 - N3) * (N4 + N5);
    if denominator == 0
        beta = 0;
    else
        arg = numerator / denominator;
        arg = max(min(arg, 1), -1);
        beta = acos(arg);
    end
    g = zeros(10, 1);
    g(1) = m2*(N6 + 2.5) - Dmax;
    g(2) = m1*(N1 + N2) + m1*(N2 + 2) - Dmax;
    g(3) = m2*(N4 + N5) + m2*(N5 + 2) - Dmax;
    g(4) = abs(m1*(N1 + N2) - m2*(N6 - N3)) - m1 - m2;
    g(5) = -(N1 + N2)*sin(pi/p) + N2 + 2 + delta22;
    g(6) = -(N6 - N3)*sin(pi/p) + N3 + 2 + delta33;
    g(7) = -(N4 + N5)*sin(pi/p) + N5 + 2 + delta55;
    g(8) = (N3 + N5 + 2 + delta35)^2 - (N6 - N3)^2 - (N4 + N5)^2 + 2*(N6 - N3)*(N4 + N5)*cos(2*pi/p - beta);
    g(9) = N4 - N6 + 2*N5 + 2*delta56 + 4;
    g(10) = 2*N3 - N6 + 2*delta34 + 4;
    h1 = mod(N6 - N4, p);
    epsilon = 1e-5;
    h_violation = abs(h1) > epsilon;
    penalty_g = panalty_factor * sum(g(g > 0).^2);
    penalty_h = panalty_factor * h_violation * (h1^2);
    total_penalty = penalty_g + penalty_h;
    fitness = f + total_penalty;
end

function fitness = Robot_Gripper(x)
    panalty_factor = 1e10;
    a     = x(1); b     = x(2); c     = x(3); e     = x(4); ff    = x(5);
    l     = x(6); delta = x(7);
    Ymin = 50; Ymax = 100; YG   = 150; Zmax = 100;
    fhd1 = @(z) F1(x, z, 2);
    options = optimset('Display','off');
    [~, fitVal1] = fminbnd(fhd1, 0, Zmax, options);
    fhd2 = @(z) -F1(x, z, 2);
    [~, fitVal2] = fminbnd(fhd2, 0, Zmax, options);
    f = -fitVal2 - fitVal1;
    g = zeros(7,1);
    g(1) = -Ymin + F1(x, Zmax, 1);
    g(2) = -F1(x, Zmax, 1);
    g(3) = Ymax - F1(x, 0, 1);
    g(4) = F1(x, 0, 1) - YG;
    g(5) = l^2 + e^2 - (a + b)^2;
    g(6) = b^2 - (a - e)^2 - (l - Zmax)^2;
    g(7) = Zmax - l;
    penalty = panalty_factor * sum(max(0,g).^2);
    fitness = f + penalty;
end

function val = F1(x, z, mode)
    a     = x(1); b     = x(2); c     = x(3); e     = x(4); ff    = x(5);
    l     = x(6); delta = x(7);
    switch mode
        case 1
            val = a + b + z/10;
        case 2
            val = (c + e + ff + l + delta) - z/5;
        otherwise
            val = 0;
    end
end
