% function [ Gbest,BestCost ] = CSO1( Costfunction1,opts )
function [ Gbest,BestCost ] = PCCSO( opts,fhd,varargin)
%-------------------------- Parameters Setting ----------------------------%
nDim = opts.dim;
nPop = opts.N;
MaxIter = opts.Max_iteration;
Showflag = opts.Showflag;
mr = 0.5;
Seek.smp = opts.smp;
Seek.srd = opts.srd;
Seek.RangeMin = opts.RangeMin;
Seek.RangeMax = opts.RangeMax;
Trace.c = opts.c;
Trace.VelMin = opts.VelMin;
Trace.VelMax = opts.VelMax;
groups=4;
nPop = opts.N/groups;
popmin=Seek.RangeMin;
popmax=Seek.RangeMax;
VelMin=Trace.VelMin;
VelMax=Trace.VelMax;
%------------------------------- The End ----------------------------------%
%-------------------------- Initialization --------------------------------%
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

n_Trace = nPop*mr;
idx_Trace = randperm(nPop,n_Trace);
idx_Seek = setdiff(1:nPop,idx_Trace);
BestCost = zeros(1,MaxIter);
it = 1;
%------------------------------- The End ----------------------------------%

Up = 10;
n=1000;
for g = 1:groups
    group(g).mu = zeros(1,nDim);
    group(g).sicma=10*ones(1,nDim);
end
%  mu = zeros(1,nDim);          %mean
% sicma = 10*ones(1,nDim);     %standard deviation
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
               func_num=28;
            A=Up*generateIndividualR(group(g).mu(i),group(g).sicma(i));
            group(g).Posi(i,:)= Up*generateIndividualR(group(g).mu(i),group(g).sicma(i));
            [group(g).Cost(i),group(g).Posi(i,:),pbest] = SeekMode_parallel( group(g).Posi(i,:),group(g).Cost(i),Seek,fhd,func_num );
            if pbest.Cost <gBest.Cost
                  gBest.Posi = pbest.Posi;
                gBest.Cost = pbest.Cost;
                group(g).mu(i) = updateMuPV( gBest.Posi,group(g).Posi(i,:),group(g).mu(i),n,1);
                group(g).sicma(i) = updateSicmaPV( gBest.Posi,group(g).Posi(i,:),group(g).mu(i),group(g).sicma(i),n,1);
                group(g).Posi(i,:) = Up*generateIndividualR(group(g).mu(i),group(g).sicma(i));
            end
        end
        %--------------------------------------------------------------------
        %--------------------------- Tracing Mode ---------------------------%
        for i = idx_Trace
            %      group(g).Posi(i,:)= Up*generateIndividualR(group(g).mu(i),group(g).sicma(i));
            [group(g).Cost(i),group(g).Posi(i,:)] = Adamode_parallel( group(g).Posi(i,:),group(g).Cost(i), group(g).Velo(i),gBest,opts);
           group(g).Cost(i) = feval(fhd,( group(g).Posi(i,:)  )',varargin{:});
            if  group(g).Cost(i) < gBest.Cost
                %               group(g).mu(i) = updateMuPV( group(g).Posi(i,:),gBest.Posi,group(g).mu(i),n,1);
                %              group(g).sicma(i) = updateSicmaPV( group(g).Posi(i,:),gBest.Posi,group(g).mu(i),group(g).sicma(i),n,1);
                gBest.Posi = group(g).Posi(i,:);
                gBest.Cost = group(g).Cost(i);
                %                group(g).Posi(i,:)h = Up*generateIndividualR(group(g).mu(i),group(g).sicma(i));
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
Gbest =  gBest.Cost;
end

