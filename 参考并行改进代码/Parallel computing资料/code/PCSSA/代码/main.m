clear
clc
fhd=str2func('cec13_func');

d = 30;

Max_iteration=500;
sum = zeros(1,30);
pop_size=100;
popmin=-100;
popmax=100;
count=0;
mean1=zeros(28,4);
best=zeros(28,4);
std1=zeros(28,4);

% tic

for i=1:1
 func_num=i;
 for j=1:1

%     [Best_score1(i,j),Best_pos1,Convergence_curve1]=PSO(fhd,d,pop_size,Max_iteration,popmin,popmax,func_num);
%      [Best_score2(i,j),Best_pos2,Convergence_curve2]=SSA(fhd,d,pop_size,Max_iteration,popmin,popmax,func_num);
%     [Best_score3(i,j),Best_pos3,Convergence_curve3]=SCA(fhd,d,pop_size,Max_iteration,popmin,popmax,func_num);
      [Best_score4(i,j),Best_pos4,Convergence_curve4]=CSSA(fhd,d,pop_size,Max_iteration,popmin,popmax,func_num);
 end
 %求30次平均值
 
%  mean1(i,1)=mean(Best_score1(i,:));
%  mean1(i,2)=mean(Best_score2(i,:));
%  mean1(i,3)=mean(Best_score3(i,:));
 mean1(i,4)=mean(Best_score4(i,:));
 %求30次最优值
% best(i,1)=min(Best_score1(i,:));
% best(i,2)=min(Best_score2(i,:));
% best(i,3)=min(Best_score3(i,:));
best(i,4)=min(Best_score4(i,:));
%  %求30次的标准差
% std1(i,1)=std(Best_score1(i,:));
% std1(i,2)=std(Best_score2(i,:));
% std1(i,3)=std(Best_score3(i,:));
std1(i,4)=std(Best_score4(i,:));
end

%  toc

%      plot(Convergence_curve1,'r');
%        hold on
%  plot(Convergence_curve2,'b'); 
%  plot(Convergence_curve3,'g');
%  plot(Convergence_curve4,'y'); 
%       hold off
  % legend('pso','ssa')  
% disp(Best_score);
% disp(i);
%   disp(Best_pos2);
%  disp(Best_pos4);
%   if Best_pos4<Best_pos2
%      count=count+1;
%   end

%   disp(count);

%    plot(Convergence_curve1,'r');
%    hold on
%       plot(Convergence_curve2,'b'); 
%       plot(Convergence_curve3,'g');
%       plot(Convergence_curve4,'y');  
%    hold off
%      grid on
%      xlabel('Iteration');
%      ylabel('Fitness function value');
%      legend('PSO','SSA','SCA','PCSSA');
%  print(gcf,'-depsc','DE-f1.eps')
