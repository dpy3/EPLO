% function [ Gbest,BestCost ] = CSO1( Costfunction1,opts )
function [ Gbest,BestCost ] = PCSO( opts,fhd,varargin)
%-------------------------- Parameters Setting ----------------------------%
nDim = opts.dim;
nPop = opts.N;
MaxIter = opts.Max_iteration;
Showflag = opts.Showflag;
mr = opts.mr;
Seek.smp = opts.smp;
Seek.srd = opts.srd;
Seek.RangeMin = opts.RangeMin;
Seek.RangeMax = opts.RangeMax;
Trace.c = opts.c;
Trace.VelMin = opts.VelMin;
Trace.VelMax = opts.VelMax;
groups = 8;
nPop = opts.N/groups;
popmin=Seek.RangeMin;
popmax=Seek.RangeMax;
VelMin=Trace.VelMin;
VelMax=Trace.VelMax;
%------------------------------- The End ----------------------------------%
%-------------------------- Initialization --------------------------------%
% empty_cat.Posi  = zeros(1,nDim);
% empty_cat.Cost  = zeros(1,1);
for g = 1:groups
    for i = 1:nPop
        % 随机产生一个种群
        group(g).Posi(i,:) = popmin+(popmax-popmin).*rand(1,nDim);    %初始种群
        group(g).Velo(i,:) = VelMin+(VelMax-VelMin).*rand(1,nDim);  %初始化速度
        % 计算适应度
        group(g).Cost(i) = feval(fhd,( group(g).Posi(i,:)  )',varargin{:});
    end
end
for g = 1:groups
    [group(g).bestfitness,group(g).bestindex] = min(group(g).Cost(i));
    %     group(g).GP = group(g).bestindex;
    group(g).gbest = group(g).Posi(group(g).bestindex,:);   %全局最佳
    group(g).fitnessgbest = group(g).bestfitness;%全局最佳适应度值
    gBest.Cost= group(1).fitnessgbest;
   gBest.Posi = group(1).gbest;
end;
for g = 1:groups
    if group(g).fitnessgbest< gBest.Cost
         gBest.Cost = group(g).fitnessgbest;
        gBest.Posi = group(g).gbest;
    end
end
% gBest.Posi      = zeros(1,nDim);
% gBest.Cost = inf;
% 
% empty_cat.Velo  = zeros(1,nDim);
% cat   = repmat(empty_cat,nPop,1);

% for i = 1:nPop
%     cat(i).Posi = unifrnd( Seek.RangeMin,Seek.RangeMax,[1,nDim] );
%  
%     cat(i).Cost = CostFunction( cat(i).Posi );
% %     cat(i).Cost = fhd( cat(i).Posi );
%     cat(i).Velo = unifrnd( Trace.VelMin,Trace.VelMax,[1,nDim] );
%     
%     if cat(i).Cost < gBest.Cost
%         gBest.Posi = cat(i).Posi;
%         gBest.Cost = cat(i).Cost;
%     end
% end

n_Trace = nPop*mr;
idx_Trace = randperm(nPop,n_Trace);
idx_Seek = setdiff(1:nPop,idx_Trace);
BestCost = zeros(1,MaxIter);
it = 1;
%------------------------------- The End ----------------------------------%

while it<=MaxIter
    
    %--------------------------- Seeking Mode ---------------------------%
    for g=1:groups
            if rem(MaxIter,20) == 0%R1=20,20代交流一次，
            RH = int8(rand*nPop);%head，sizepop种群数量
            RE = RH+int8(rand*(nPop/4));%end
            RH = max(1,min(nPop,RH));
            RE = max(1,min(nPop,RE));
            for r = RH:RE
                for d = 1:nDim
                    group(g).Posi(r,d) =  gBest.Posi(d)*(0.9+0.2*rand);%每一组都用TotalBest取代
                    
                end
                 pbest.Posi(r,:) = gBest.Posi;
               pbest.Cost(r) =  gBest.Cost;
            end
%             group(g).gbest = gBest.Posi;
%             group(g).fitnessgbest =  gBest.Cost;
        end
    for i = idx_Seek
%         q=group(g).Posi(i,:);
%          [c,d,pbest] = SeekMode_parallel(group(g).Posi(i,:), group(g).Cost(i),CostFunction,Seek );
%           c=c;
%           d=d;
%           group(g).Cost(i)=c;
%           group(g).Posi(i,:)=d;
              func_num=1;
            [group(g).Cost(i),group(g).Posi(i,:),pbest] = SeekMode_parallel( group(g).Posi(i,:),group(g).Cost(i),Seek ,fhd,func_num);
            if pbest.Cost < gBest.Cost
                gBest.Posi = pbest.Posi;
                gBest.Cost = pbest.Cost;
            end
    end
    %--------------------------------------------------------------------%
    
    %--------------------------- Tracing Mode ---------------------------%
    for i = idx_Trace
%           [a,b] = Adamode_parallel( group(g).Cost(i),group(g).Posi(i), group(g).Velo(i),gBest,opts);
%           a=a;
%           b=b;
%           group(g).Cost(i)=a;
%           group(g).Posi(i,:)=b;
        [group(g).Cost(i),group(g).Posi(i,:)] = Adamode_parallel( group(g).Posi(i,:),group(g).Cost(i), group(g).Velo(i),gBest,opts);
      group(g).Cost(i) = feval(fhd,( group(g).Posi(i,:)  )',varargin{:});
        if  group(g).Cost(i) < gBest.Cost
            gBest.Posi = group(g).Posi(i,:);
            gBest.Cost = group(g).Cost(i);
        end
    end
     end

    %--------------------------------------------------------------------%
    BestCost(it) = gBest.Cost;
    %------------------------- Resetting mode ---------------------------%
    idx_Trace = randperm(nPop,n_Trace);
    idx_Seek = setdiff(1:nPop,idx_Trace);
    %--------------------------------------------------------------------%
    
%     if Showflag
%         disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
%     end
    it = it + 1;
end
   Gbest = gBest.Cost;
end

