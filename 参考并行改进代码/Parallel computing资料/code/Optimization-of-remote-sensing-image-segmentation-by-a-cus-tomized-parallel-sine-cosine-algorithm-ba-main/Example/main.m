%% SCA算法优化脉冲耦合神经网络的图像自动分割
%读取图像
pcode s.m
clc;clear all;
close all;
I = imread('1006.jpg');
%将图像转换为灰度图

if(size(I,3)~=1)
    Igray = rgb2gray(I);
else
    Igray = I;
end

% subplot(1,3,1),imshow(I);
figure
imshow(I,[]);
% title('The original image');
% axis([0,200,0,200]);
% axis on;                  %显示坐标系
I1=rgb2gray(I);
% subplot(1,3,2),imshow(I1);
% title('Grayscale image');
% axis([0,200,0,200]);
% axis on;                  %显示坐标系

% J=imadjust(I1,[0.1 0.5],[]); %局部拉伸，把[0.1 0.5]内的灰度拉伸为[0 1]
% subplot(2,2,3),imshow(J);
% title('Linearly transform the image[0.1 0.5]');
% axis([0,200,0,200]);
% grid on;                  %显示网格线
% axis on;                  %显示坐标系

K=imadjust(I1,[0.2 0.8],[]); %局部拉伸，把[0.3 0.7]内的灰度拉伸为[0 1]
% subplot(1,3,3),imshow(K);
% title('Linearly transform the image');
% axis([0,200,0,200]);
% grid on;                  %显示网格线
% axis on;                  %显示坐标系
%%
%对连接系数β、阈值衰减系数 αE 、阈值放大数 VE进行优化
%参数范围均设置为 0．001-200
Taguchi_option=Get_Taguchi_option('EXP1');
dim = 3;%维度，3维即优化的3个参数
lb = 0.001.*ones(1,dim); %下边界
ub = 200.*ones(1,dim); %上边界
pop = 20;%种群数量
Max_iteration = 50;%最大迭代次数
fobj = @(x) fun(x,K);%适应度函数
 [Best_score_4,Best_pos_4,cg_curve_4]=TPSCA(lb,ub,dim,fobj,Taguchi_option);
SCA_curve = -SCA_curve;
Best_score = -Best_score;
[~,BWImage] = fun(Best_pos,K);
  %Draw objective space
figure
imshow(BWImage,[]);
% title('The result of TPSCA-PCNN')
display(['优化的连接系数β、阈值衰减系数 αE 、阈值放大数 VE分别为：',num2str(Best_pos)])
display(['最优信息熵值为：',num2str(Best_score)])
A=Igray;
B=BWImage;
[Accuracy1, Sensitivity1, Fmeasure1, Precision1, MCC1, Dice1, Jaccard1, Specitivity1]=EvaluateImageSegmentationScores(A, B)
%%
fobj = @(x) fun(x,Igray);%适应度函数
[Best_score,Best_pos,SCA_curve]=SCA(pop,Max_iteration,lb,ub,dim,fobj); %开始优化
SCA_curve = -SCA_curve;
Best_score = -Best_score;
[~,BWImage] = fun(Best_pos,Igray);
  % Draw objective space
% figure
% plot(TSCA_curve,'Color','b','linewidth',1.5)
% % title('TSCA-PCNN迭代曲线')
% xlabel('迭代次数');
% ylabel('信息熵值');
% axis tight
% grid on
% box on
% legend('TSCA-PCNN')
figure
imshow(BWImage,[]);
% title('TSCA-PCNN最终分割结果I')
display(['优化的连接系数β、阈值衰减系数 αE 、阈值放大数 VE分别为：',num2str(Best_pos)])
display(['最优信息熵值为：',num2str(Best_score)])
%%
A=Igray;
B=BWImage;
[Accuracy2, Sensitivity2, Fmeasure2, Precision2, MCC2, Dice2, Jaccard2, Specitivity2]=EvaluateImageSegmentationScores(A, B)


