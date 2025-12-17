% function [ Gbest,BestCost ] = CSO1( Costfunction1,opts )
function [ Gbest,BestCost ] = CCSO( opts,fhd,varargin)
%-------------------------- Parameters Setting ----------------------------%
nDim = opts.dim;
nPop = opts.N;
MaxIter = opts.Max_iteration;
Showflag = opts.Showflag;
mr = 0.9;
Seek.smp = opts.smp;
Seek.srd = opts.srd;
Seek.RangeMin = opts.RangeMin;
Seek.RangeMax = opts.RangeMax;
Trace.c = opts.c;
Trace.VelMin = opts.VelMin;
Trace.VelMax = opts.VelMax;

%------------------------------- The End ----------------------------------%
%-------------------------- Initialization --------------------------------%
empty_cat.Posi  = zeros(1,nDim);
empty_cat.Cost  = zeros(1,1);

gBest.Posi      = zeros(1,nDim);
gBest.Cost = inf;

empty_cat.Velo  = zeros(1,nDim);
cat   = repmat(empty_cat,nPop,1);

for i = 1:nPop
    cat(i).Posi = unifrnd( Seek.RangeMin,Seek.RangeMax,[1,nDim] );
    cat(i).Cost = feval(fhd,(cat(i).Posi )',varargin{:});
    %     cat(i).Cost = fhd( cat(i).Posi );
    cat(i).Velo = unifrnd( Trace.VelMin,Trace.VelMax,[1,nDim] );
    
    if cat(i).Cost < gBest.Cost
        gBest.Posi = cat(i).Posi;
        gBest.Cost = cat(i).Cost;
    end
end

n_Trace = fix(nPop*mr);
n_Trace =2;
idx_Trace = randperm(nPop,n_Trace);
idx_Seek = setdiff(1:nPop,idx_Trace);
BestCost = zeros(1,MaxIter);
it = 1;
%------------------------------- The End ----------------------------------%
Up = 10;
  n=1000;
 mu = zeros(1,nDim);          %mean
sicma = 10*ones(1,nDim);     %standard deviation
while it<=MaxIter
    
    %--------------------------- Seeking Mode ---------------------------%
    for i = idx_Seek
        func_num=1;
        cat(i).Posi= Up*generateIndividualR(mu,sicma);
        [cat(i),pbest] = SeekMode_CCSO( cat(i),Seek,fhd,func_num );
        if pbest.Cost < gBest.Cost
              gBest.Posi = pbest.Posi;
            gBest.Cost = pbest.Cost;
             mu = updateMuPV(  gBest.Posi,cat(i).Posi,mu,n,1);
             sicma = updateSicmaPV(gBest.Posi,cat(i).Posi,mu,sicma,n,1);
             cat(i).Posi = Up*generateIndividualR(mu,sicma);
        end
    end
    %--------------------------------------------------------------------
    %--------------------------- Tracing Mode ---------------------------%
    for i = idx_Trace
%         cat(i).Posi= Up*generateIndividualR(mu,sicma);
        cat(i) = Adamode( cat(i),gBest,opts);
       cat(i).Cost = feval(fhd,(cat(i).Posi )',varargin{:});
        if cat(i).Cost < gBest.Cost
%             mu = updateMuPV(  cat(i).Posi,gBest.Posi,mu,n,1);
%             sicma = updateSicmaPV( cat(i).Posi,gBest.Posi,mu,sicma,n,1);
            gBest.Posi = cat(i).Posi;
            gBest.Cost = cat(i).Cost;
%                cat(i).Posi = Up*generateIndividualR(mu,sicma);
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

