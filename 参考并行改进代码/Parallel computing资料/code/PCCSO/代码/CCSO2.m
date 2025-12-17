function [Gbest,T] =CCSO2( fhd,Dimension,Particle_Number,Mr,srd,smp,c,Max_Gen,VelMin,VelMax,popmin,popmax,varargin )
%CSO 此处显示有关此函数的摘要
%   此处显示详细说明CSO
%-------------------------- Parameters Setting ----------------------------%
rand('state',sum(100*clock));
% w = 0.9;
nDIM =Dimension;
mr=Mr;
nDim=10;
% Seek.srd=srd;
% Seek.smp=smp;
maxgen = Max_Gen;

nPOP = Particle_Number;

% Seek.popmax = popmax;
% Seek.popmin = popmin;
% Trace.c=c;
% Trace.VelMin=VelMin;
% Trace.VelMax=VelMax;
% spc = rand();
r = rand();
Max = -inf;
%------------------------------- The End ----------------------------------%
%-------------------------- Initialization --------------------------------%
%..

    for i = 1:nPOP
        % 随机产生一个种群
       pop(i,:) = popmin+(popmax-popmin)*rand(1,nDIM);    %初始种群
       V(i,:) = VelMin+(VelMax-VelMin)*rand(1,nDIM);  %初始化速度
        % 计算适应度
    end
    fitness = feval(fhd,pop',varargin{:});%。。。。。。。。。。。。。


    [bestfitness,bestindex] = min(fitness);
%     group(g).GP = group(g).bestindex;
    gbest = pop(bestindex,:);   %全局最佳
   fitnessgbest = bestfitness;%全局最佳适应度值
    Gbest = fitnessgbest;
    GbestPosition = gbest;


    if fitnessgbest<Gbest
        Gbest = fitnessgbest;
        GbestPosition = gbest;
    end

Up = 10;
n=1000;
mu = zeros(1,nDim);
sicma=10*ones(1,nDim);

n_Trace = nPOP*mr;

%  n_Trace = 4;
%------------------------------- The End ----------------------------------%
for G = 1:maxgen
    
    idx_Trace = randperm(nPOP,n_Trace);
    idx_Seek = setdiff(1:nPOP,idx_Trace);
    
        %--------------------------- Seeking Mode ---------------------------%
        for i = 1:size(idx_Seek)
           pop(idx_Seek(i),:)= Up*generateIndividualR(mu ,sicma);
            spc = rand;
            %% 肯定是每个seeking cat 的spc都不一样！！！怎么能在开头定义成全局变量！！！
            
            if spc<0.5
                flag = 0;
            else
                flag = 1;
            end
            
            Copypop= repmat(pop(idx_Seek(i),:),smp,1);%..
           Copyfitness=repmat(fitness(idx_Seek(i)),smp,1);
            Sign = rand(smp,nDIM);
            Sign( Sign>=0.5 ) = 1;
            Sign( Sign<0.5 ) = -1;
            val = srd.*abs(pop(idx_Seek(i),:));
            if flag == 0
                for j = 1:smp
                    Copypop(j,:) = pop(idx_Seek(i),:)+ Sign(j,:).*val;  %初始种群
                    Copypop(j,:) = min(popmax,max(popmin,Copypop(j,:)));
                    %                     group(g).Copyfitness(j) = feval(fhd,group(g).Copypop(j,:)' ,varargin{:}); %初始化速度
                    %                     if group(g).Copyfitness(j) > Max
                    %                         Max = group(g).Copyfitness(j);
                    %                     end
                    %                     if group(g).Copyfitness(j)  < group(g).fitnessgbest
                    %                         group(g).gbest = group(g).Copypop(j,:);
                    %                         group(g).fitnessgbest =group(g).Copyfitness(j);
                    %                     end
                end
                %% copy的cat应该寻找一个最优值，并找到最优值的位置
            else
                %                  group(g).gbest = group.pop;
                %                 group(g).fitnessgbest= feval(fhd, group(g).gbest,varargin{:});
                %% 应该将第idx_Seek（i)只猫赋值与第一个copy
               Copy(1,:) = pop(idx_Seek(i),:);
                for j = 2:smp
                   Copypop(j,:)=  pop(idx_Seek(i),:)+Sign(j,:).*val;
                    for d = 1:nDIM
                        Copypop(j,:) = min(popmax,max(popmin,Copypop(j,:)));
                    end
                    %                     group(g).Copyfitness(j) =feval(fhd,group(g).Copypop(j,:)',varargin{:});
                    %
                    %                     if   group(g).Copyfitness(j)> Max
                    %                         Max =  group(g).Copyfitness(j);
                    %                     end
                    %                 end
                    %% 同理，寻找一个最优的值和坐标
                    %                 if group(g).Copyfitness(idx_Seek(i))  < group(g).fitnessgbest
                    %                     group(g).gbest = group(g).Copypop(i,:);
                    %                     group(g).fitnessgbest =group(g).Copyfitness(i);
                    %                 end
                end
                
            end
           Copyfitness = feval(fhd,Copypop',varargin{:});
            [mincopyfitness,mincopyidex] = min(Copyfitness);
            [maxcopyfitness,maxcopyidex] = max(Copyfitness);
           Selection = rand;
            for j = 1:smp
                p(j) = abs((Copyfitness(j)-maxcopyfitness))/(maxcopyfitness-mincopyfitness);
                if Selection < p(j)
                   fitness(idx_Seek(i)) = Copyfitness(j);
                   pop(idx_Seek(i),:) =Copypop(j,:);
                    break;
                end
            end
           
            if fitness(idx_Seek(i)) < fitnessgbest
                               fitnessgbest = fitness(idx_Seek(i));
               gbest = pop(idx_Seek(i),:);
                
             mu = updateMuPV( gbest ,pop(idx_Seek(i),:),mu,n,nDIM);
             sicma = updateSicmaPV( gbest ,pop(idx_Seek(i),:),mu,sicma,n,nDIM);  
             pop(idx_Seek(i),:)= Up*generateIndividualR(mu,sicma);

            end
        end
            %% seek过程整个结束，再更新种群的fitness最优值，顺便找到fitness Max值
            
            
            %--------------------------------------------------------------------%
            %--------------------------- Tracing Mode ---------------------------%
            
          for m = 1:size(idx_Trace,2)
                %-------------------------- updata velocity ------------------------%
               V(idx_Trace(m),:) = V(idx_Trace(m),:)+rand()*c*(gbest-pop(idx_Trace(m),:));
                for d = 1:nDIM
                    V(idx_Trace(m),d) = min(VelMax,max(VelMin,V(idx_Trace(m),d)));
                end
                %-------------------------------------------------------------------%
                
                %-------------------------- updata location ------------------------%
                pop(idx_Trace(m),:) =pop(idx_Trace(m),:)+V(idx_Trace(m),:);%更新位置公式
                 for d = 1:nDIM
                     pop(idx_Trace(m),d) = min(popmax,max(popmin,pop(idx_Trace(m),d)));
                end
                %-------------------------------------------------------------------%
            end
            
           
           fitness = feval(fhd,pop',varargin{:});
          
            for i = 1:nPOP
                if fitness(i)<fitnessgbest
                   fitnessgbest =fitness(i);
                    gbest = pop(i,:);
                    %
                end
                if fitnessgbest < Gbest
                    Gbest = fitnessgbest;
                    GbestPosition =gbest;
                end
            end

    %     T(G) = groupgBest.Cost;
    idx_Trace = randperm(nPOP,n_Trace);
    idx_Seek = setdiff(1:nPOP,idx_Trace);
    
    %------------------------------- The End ----------------------------------%
    T(G) = Gbest;
end

%figure(varargin{:});
% plot(T(1:50:1000),'r-o','LineWidth',1,'Marker','o','MarkerFaceColor','red');
% hold on;
% legend('CSO');

end






