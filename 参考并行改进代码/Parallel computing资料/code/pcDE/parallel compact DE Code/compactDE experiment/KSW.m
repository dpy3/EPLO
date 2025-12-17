close all;
clear;
global P
A=rgb2gray(imread('lena.jpg'));
% B=imbinarize(A,150/255);
[row,col]=size(A);
m=1;
n=1;
C=padarray(A,[m n],'replicate');
avg=zeros(row,col);
N=10^-1*zeros(256,256);
for i=1:row
    for j=1:col
       avg(i,j)=floor(sum(sum(C(i:i+2*n,j:j+2*m)))/((2*n+1)*(2*m+1)));
       N((A(i,j)+1),(avg(i,j)+1))=N((A(i,j)+1),(avg(i,j)+1))+1;
    end
end
P=N/(row*col);
for i=1:256
    for j=1:256
       if P(i,j)==0
           P(i,j)=10^(-10);
       end
    end
end
DE(256,0,2,29,0.1,0.1);

figure
surf(1:1:256,1:1:256,P);
figure
subplot(131);
imshow(avg/255);
subplot(132);
imshow(A);
subplot(133);
imhist(A)


% function fitness=ksw(t)
% a=floor(t(1));
% b=floor(t(2));
% PA=sum(sum(P(1:a,1:b)));
% HA=log(PA)+(-sum(sum(P(1:a,1:b).*log(P(1:a,1:b)))))/PA;
% HL=-sum(sum(P.*log(P)));
% fitness=log(PA*(1-PA))+HA/PA+(HL-HA)/(1-PA);
% end













