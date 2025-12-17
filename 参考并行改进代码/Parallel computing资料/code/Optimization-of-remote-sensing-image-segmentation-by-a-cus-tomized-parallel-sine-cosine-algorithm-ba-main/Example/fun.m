%% 适应度函数
function [fitness,BWImage] = fun(x,Igray)
Igray = im2double(Igray); %图像归一化

[m,n] = size (Igray); 
%************************************************************ 
% 初始化参数PCNN参数
%************************************************************ 
% P ：L E F VF VL VE beta 
% V: 1.0 1.0 0.1 0.5 0.2 20 0.1 
%连接系数
B = x(1);
%阈值衰减系数
ae = x(2);
%阈值放大系数
ve = x(3);

al = 1.0; af = 0.1; vf = 0.5; vl = 0.2; 
W =[0.707 1 0.707;... 
        1 0 1;...    
        0.707 1 0.707]; 
M = W; Y = zeros(m,n); F = Y; L = Y; U = Y; E = Y; 
%************************************************************ 
% PCNN 点火过程 
%************************************************************ 
for i = 1:30
    wk = conv2(Y,M,'same');
    F = exp(-af).* F + vf.* wk + Igray; 
    L = exp(-al).* L + vl.* wk; 
    U = F.*(1 + B.* L); 
    Y = double(U>E); 
    E = exp(-ae).* E + ve.* Y; 
end
BWImage = Y;
[r,c] = size(BWImage);
%图像熵计算
p1 = sum(BWImage(:))/(r*c);
p0 = 1 - p1;
H = -p1*log2(p1)-p0*log2(p0);
%目的是熵最大，由于优化函数是找最小值，于是加个符号，转换为求最小值问题
fitness = -H;
if(isnan(fitness) || isinf(H))%可能存在log2(0)的情况，nan
    fitness = inf;
end
end