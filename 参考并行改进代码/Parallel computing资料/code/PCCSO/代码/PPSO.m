% function [TotalBest,T] = PP( fhd,Dimension,Particle_Number,Max_Gen,VRmin,VRmax,Popmin,Popmax,varargin )
function [TotalBest,T] = PPSO(opts,CostFunction)
%PP 此处显示有关此函数的摘要
%   此处显示详细说明
rand('state',sum(100*clock));
c = 2.0;
groups = 4;
w = 0.9;
D =  opts.dim;
sizepop = opts.N/groups;
maxgen = opts.Max_iteration;
Vmax =opts.VelMax;
Vmin = opts.VelMin;
popmax = opts.RangeMax ;
popmin =opts.RangeMin;
popmin= -5 + (5).*rand(1,1);
popmax = 10 + (15-10).*rand(1,1);
Vmin =-0.1*popmax;
Vmax = -Vmin ;
for g = 1:groups
    for i = 1:sizepop
        % 随机产生一个种群
        group(g).pop(i,:) = popmin+(popmax-popmin)*rand(1,D);    %初始种群
        group(g).V(i,:) = Vmin+(Vmax-Vmin)*rand(1,D);  %初始化速度
        % 计算适应度
           group(g). fitness(i) = CostFunction(group(g).pop(i,:));
    end
%     group(g).fitness = feval(fhd,group(g).pop',varargin{:});%。。。。。。。。。。。。。
end

%% V. 个体极值和群体极值
for g = 1:groups
    [group(g).bestfitness,group(g).bestindex] = min(group(g).fitness);
    group(g).GP = group(g).bestindex;
    group(g).pbest = group(g).pop;    %个体最佳
    group(g).gbest = group(g).pop(group(g).bestindex,:);   %全局最佳
    group(g).fitnesspbest = group(g).fitness;%个体最佳适应度值
    
    group(g).fitnessgbest = group(g).bestfitness;%全局最佳适应度值
    
    TotalBest = group(1).fitnessgbest;
    TotalBestPosition = group(1).gbest;   
end;
for g = 1:groups
    if group(g).fitnessgbest<TotalBest
        TotalBest = group(g).fitnessgbest;
        TotalBestPosition = group(g).gbest;
    end
end


for G = 1:maxgen%当前迭代次数
    
    for g = 1:groups
        if rem(G,20) == 0%R1=20,20代交流一次，
            RH = int8(rand*sizepop);%head，sizepop种群数量
            RE = RH+int8(rand*(sizepop/4));%end
            RH = max(1,min(sizepop,RH));
            RE = max(1,min(sizepop,RE));
            for r = RH:RE
                for d = 1:D
                    group(g).pop(r,d) = TotalBestPosition(d)*(0.9+0.2*rand);%每一组都用TotalBest取代
                    
                end
                group(g).pbest(r,:) = TotalBestPosition;
                group(g).fitnesspbest(r) = TotalBest;
            end
            group(g).gbest = TotalBestPosition;
            group(g).fitnessgbest = TotalBest;
        end
        for i = 1:sizepop
            group(g).V(i,:) = w*group(g).V(i,:)+c*rand*(group(g).pbest(i,:)...
                -group(g).pop(i,:))+c*rand*(group(g).gbest-group(g).pop(i,:));
            
            for d = 1:D
                group(g).V(i,d) = max(Vmin,min(Vmax,group(g).V(i,d)));
            end
            
            % 种群更新
            group(g).pop(i,:) = group(g).pop(i,:)+group(g).V(i,:);
            
            %确保粒子位置不超出边界
            for d = 1:D
                group(g).pop(i,d) = max(popmin,min(popmax,group(g).pop(i,d)));
            end
            group(g). fitness(i) = CostFunction(group(g).pop(i,:));
            
        end
%         group(g).fitness = feval(fhd,group(g).pop',varargin{:});
        for i = 1:sizepop
            if group(g).fitness(i)<group(g).fitnesspbest(i)
                group(g).fitnesspbest(i) = group(g).fitness(i);
                group(g).pbest(i,:) = group(g).pop(i,:);
            end
            
            if group(g).fitness(i)<group(g).fitnessgbest
                group(g).fitnessgbest = group(g).fitness(i);
                group(g).gbest = group(g).pop(i,:);
%                 group(g).GP = i;
            end
        end
        if group(g).fitnessgbest <TotalBest
            TotalBest = group(g).fitnessgbest;
            TotalBestPosition = group(g).gbest;
        end
    end
    
    %     Tbest(G) = TotalBest;
    T(G) = TotalBest;
end
% figure(varargin{:});
%  plot(T(1:50:1000),'g-','LineWidth',1,'Marker','d','MarkerFaceColor','g');
% legend('PSO','PPSO');
end

