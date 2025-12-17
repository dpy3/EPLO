function [ Gbest,BestCost ] = CSO( opts,fhd,varargin)
dim=10;
ub=10;
lb=-ub;
mr = 0.8;  
func_num=28;
Seek.smp = 40;
Seek.srd = 0.8;
spc=0.2;
CDC=0.8;
nPop = opts.N;
Trace.c = 1.05;
MaxIter = opts.Max_iteration;
Trace.VelMin = -0.1*( ub-lb );
Trace.VelMax = 0.1*( ub-lb );
 empty_cat.Posi  = zeros(1,dim);
    empty_cat.Cost  = zeros(1,1);
    gBest.Posi= zeros(1,dim);
    gBest.Cost = inf;
    
    empty_cat.Velo  = zeros(1,dim);
    cat= repmat(empty_cat,nPop,1);
    
    for i = 1:nPop
        cat(i).Posi = unifrnd( lb,ub,[1,dim] );
  cat(i).Cost = feval(fhd,(cat(i).Posi )',varargin{:});
        cat(i).Velo = unifrnd( Trace.VelMin,Trace.VelMax,[1,dim] );
        
        if cat(i).Cost < gBest.Cost
            gBest.Posi = cat(i).Posi;
            gBest.Cost = cat(i).Cost;
        end
    end
    
    n_Trace = ceil(nPop*mr);
    idx_Trace = randperm(nPop,n_Trace); %从npop中随机选取tracing model猫
    idx_Seek = setdiff(1:nPop,idx_Trace);%seeking=npop-tracing
   it = 1;
%------------------------------- The End ----------------------------------%

while it<=MaxIter
%         it=it+1;
        %     while it<=MaxIter
        %--------------------------- Seeking Mode ---------------------------%
        for i = idx_Seek
            [cat(i)] = SeekingMode( cat(i),fhd,Seek,func_num,dim,spc,CDC);
            if cat(i).Cost < gBest.Cost
                gBest.Posi = cat(i).Posi;
                gBest.Cost = cat(i).Cost;
            end
        end
        %--------------------------------------------------------------------%
        
        %--------------------------- Tracing Mode ---------------------------%
        for i = idx_Trace
            cat(i) = TracingMode( cat(i),gBest,Trace );
              cat(i).Cost = feval(fhd,(cat(i).Posi )',varargin{:});
%             cat(i).Cost = cec13_func(cat(i).Posi',func_num);
            if cat(i).Cost < gBest.Cost
                gBest.Posi = cat(i).Posi;
                gBest.Cost = cat(i).Cost;
            end
        end
        %--------------------------------------------------------------------%
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