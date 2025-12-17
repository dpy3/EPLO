%  function [ Gbest,BestCost ] = CSO( CostFunction,opts )
%-------------------------- Parameters Setting ----------------------------%
fhd=str2func('cec13_func');
func_num=28;
nPop = 30;
% MaxIter =200;
n_circle=10;
dim=10;
ub=10;
lb=-ub;

mr = 0.02;
Seek.smp = 5;
Seek.srd = 0.2;
spc=0.2;
CDC=0.8;
% Seek.RangeMin = opts.RangeMin;
% Seek.RangeMax = opts.RangeMax;

Trace.c = 2.05;
Trace.VelMin = -0.1*( ub-lb );
Trace.VelMax = 0.1*( ub-lb );

%------------------------------- The End ----------------------------------%
Time1=[300,n_circle];

for ii=1:n_circle
    %-------------------------- Initialization --------------------------------%
    empty_cat.Posi  = zeros(1,dim);
    empty_cat.Cost  = zeros(1,1);
    
    gBest.Posi= zeros(1,dim);
    gBest.Cost = inf;
    
    empty_cat.Velo  = zeros(1,dim);
    cat= repmat(empty_cat,nPop,1);
    
    for i = 1:nPop
        cat(i).Posi = unifrnd( lb,ub,[1,dim] );
        cat(i).Cost =cec13_func( cat(i).Posi',func_num );
        cat(i).Velo = unifrnd( Trace.VelMin,Trace.VelMax,[1,dim] );
        
        if cat(i).Cost < gBest.Cost
            gBest.Posi = cat(i).Posi;
            gBest.Cost = cat(i).Cost;
        end
    end
    
    n_Trace = ceil(nPop*mr);
    idx_Trace = randperm(nPop,n_Trace); %从npop中随机选取tracing model猫
    idx_Seek = setdiff(1:nPop,idx_Trace);%seeking=npop-tracing
    
    
    %------------------------------- The End ----------------------------------%
    time=0;
    it = 0;
    tic;
    while (time<=30)
        it=it+1;
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
            cat(i).Cost = cec13_func(cat(i).Posi',func_num);
            if cat(i).Cost < gBest.Cost
                gBest.Posi = cat(i).Posi;
                gBest.Cost = cat(i).Cost;
            end
        end
        %--------------------------------------------------------------------%
        
        %------------------------- Resetting mode ---------------------------%
        idx_Trace = randperm(nPop,n_Trace);
        idx_Seek = setdiff(1:nPop,idx_Trace);
        %--------------------------------------------------------------------%
        
        %     if Showflag
        %         disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
        %     end
        
        time=toc;
        CSOBestCost(it,ii) = gBest.Cost;
        TimeCSO(it,ii)=time;
    end
    %     Gbest = gBest;
    T=1;
    for i=1:it
        if floor(TimeCSO(i,ii)*10)==T
            Time1(T,ii)=CSOBestCost(i,ii);
            T=T+1;
        end
    end
end
 
averCSO=mean(CSOBestCost,2);
stdCSO=std(CSOBestCost,0,2);
averTimeCSO=mean(Time1,2);
%%
% figure
% plot(averTimeCSO,'Color','r')
% xlabel('time')
% ylabel('avervalue')


save('CSOdata.mat','CSOBestCost','TimeCSO','averTimeCSO','averCSO','stdCSO');
