%% 单独脉冲耦合神经网络的图像自动分割
%读取图像
I = imread('1006.jpg');
%将图像转换为灰度图
if(size(I,3)~=1)
    Igray = rgb2gray(I);
else
    Igray = I;
end
Igray = im2double(Igray); %图像归一化

[m,n] = size (Igray); 
%************************************************************ 
% 初始化参数PCNN参数
%************************************************************ 
% P ：L E F VF VL VE beta 
% V: 1.0 1.0 0.1 0.5 0.2 20 0.1 
%连接系数
B = 0.1
%阈值衰减系数
ae = 1.0;
%阈值放大系数
ve = 50;

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
figure
imshow(BWImage,[]);
title('PCNN分割后的图')

disp(['PCNN分割后的信息熵值',num2str(H)])
A=Igray;
B=BWImage;
[Accuracy3, Sensitivity3, Fmeasure3, Precision3, MCC3, Dice3, Jaccard3, Specitivity3]=EvaluateImageSegmentationScores(A, B)


