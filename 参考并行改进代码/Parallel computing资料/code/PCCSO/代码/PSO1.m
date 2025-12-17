function [fitnessgbest,t] = PSO1(opts,fhd,varargin)
%PSO 此处显示有关此函数的摘要
%   此处显示详细说明

rand('state',sum(100*clock));



c = 2.0;
w = 0.9;
D =  opts.dim;
sizepop = opts.N;
maxgen = opts.Max_iteration;
Vmax =100;
Vmin = -100;
popmax =100 ;
popmin =-100;
for i = 1:sizepop
    % 随机产生一个种群
    pop(i,:) = popmin+(popmax-popmin).*rand(1,D);    %初始种群
    V(i,:) = Vmin+(Vmax-Vmin).*rand(1,D);  %初始化速度
    % 计算适应度

    fitness(i) = feval(fhd,( pop(i,:) )',varargin{:});
end
%fitness = feval(fhd,pop',varargin{:});


%% V. 个体极值和群体极值

[bestfitness,bestindex] = min(fitness);
GP = bestindex;
pbest = pop;    %个体最佳
gbest = pop(bestindex,:);   %全局最佳
fitnesspbest = fitness;%个体最佳适应度值

fitnessgbest = bestfitness;%全局最佳适应度值





for G = 1:maxgen
%     w = fix(10-5*G/maxgen)/10;
    
    for i = 1:sizepop
        V(i,:) = V(i,:)+rand*(pbest(i,:) -pop(i,:))+(gbest-pop(i,:));
%         V(i,:) = max(Vmin,min(Vmax,V(i,:))); 
        pop(i,:) = pop(i,:)+V(i,:);
%         pop(i,:) = max(popmin,min(popmax,pop(i,:)));
        
 %        fitness(i) = feval(fhd,pop(i,:)',varargin{:});
     fitness(i) = feval(fhd,( pop(i,:) )',varargin{:});
        
        if fitness(i)<fitnesspbest(i)
            fitnesspbest(i) = fitness(i);
%             pbest(i,:) = pop(i,:);
           if fitness(i)<fitnessgbest
              fitnessgbest = fitness(i);
                gbest = pop(i,:);
           end
        end
    end 
     t(G) =  fitnessgbest;
end

% figure(varargin{:});
%
% plot(T(1:50:1000),'r-o','LineWidth',1,'Marker','o','MarkerFaceColor','red');
% hold on;
% legend('PSO');
end

