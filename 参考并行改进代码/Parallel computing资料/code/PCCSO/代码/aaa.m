function [ gbest,fitnessgbest,T ] = DV_Hop_CSO(  Dimension, Particle_Number,Max_Gen,Popmin,Popmax, Distance,m,BeaconAmount,Beacon,hop1 )
%CSO 此处显示有关此函数的摘要
%   此处显示详细说明CSO
%-------------------------- Parameters Setting ----------------------------%
rand('state',sum(100*clock));
mr=0.9;
smp = 100;
srd  = 0.9;
cdc = 0.8;
c = 1.05;
nDIM =Dimension;
popmax = Popmax;
popmin =Popmin;
maxgen = Max_Gen*25;
VelMax = Popmax/10;
VelMin = -VelMax;
nPOP =4;
r = rand();
Max = -inf;
Up = 100;
n=1000;
r = rand();
Max = -5;
for i = 1:nPOP
    % 随机产生一个种群
    pop(i,:) = popmin+(popmax-popmin).*rand(1,nDIM);    %初始种群
    V(i,:) = VelMin+(VelMax-VelMin).*rand(1,nDIM);  %初始化速度
    % 计算适应度
    fitness(:,i)=fun_w(Distance,pop(i,:),m,BeaconAmount,Beacon,hop1);
end
[bestfitness,bestindex] = min(fitness);
%     group(g).GP = group(g).bestindex;
gbest = pop(bestindex,:);   %全局最佳
fitnessgbest = bestfitness;%全局最佳适应度值
Gbest = fitnessgbest;
GbestPosition =gbest;
if fitnessgbest<Gbest
    Gbest = fitnessgbest;
    GbestPosition = gbest;
end
n_Trace =fix( nPOP*mr);
idx_Trace = randperm(nPOP,n_Trace);
idx_Seek = setdiff(1:nPOP,idx_Trace);
for G = 1:maxgen
    %--------------------------- Seeking Mode ---------------------------%
    for i = 1:size(idx_Seek)
         mu = zeros(1,nDIM);          %mean
        sicma = 10*ones(1,nDIM);     %standard deviation
        pop(idx_Seek,:)= Up*generateIndividualR(mu,sicma);
        spc = rand;
        %% 肯定是每个seeking cat 的spc都不一样！！！怎么能在开头定义成全局变量！！！
        
        if spc<0.5
            flag = 0;
        else
            flag = 1;
        end
        fitness(:,idx_Seek(i))=fun_w(Distance,pop(idx_Seek(i),:),m,BeaconAmount,Beacon,hop1);
        %         fitness(idx_Seek(i))=fhd(pop(idx_Seek(i),:));
        Copypop= repmat(pop(idx_Seek(i),:),smp,1);%..
        %             group(g).Copyfitness=repmat(group(g).fitness(idx_Seek(i)),smp,1);
        Sign = rand();
        Sign( Sign>=0.5 ) = 1;
        Sign( Sign<0.5 ) = -1;
        
        para2chang_no = fix(Dimension*cdc);%朝零四舍五入
        para2change = randperm(Dimension,para2chang_no);
        if flag == 0
            pbest = zeros(1,nDIM);
            pbestfitness = inf;
            for j = 1:smp
                for d = 1:para2chang_no
                    Copypop(j,para2change(d)) = (1+Sign*srd)*pop(idx_Seek(i),para2change(d));  %初始种群
                end
                Copypop(j,:) = min(popmax,max(popmin,Copypop(j,:)));
                Copyfitness(:,j)=fun_w(Distance,Copypop(i,:),m,BeaconAmount,Beacon,hop1);
                if Copyfitness(:,j)> Max
                    Max = Copyfitness(:,j);
                end
                if Copyfitness(:,j) <  pbestfitness
                    pbest =  Copypop(j,:);
                    pbestfitness  = Copyfitness(:,j);
                    g=i;
                end
            end
            %% copy的cat应该寻找一个最优值，并找到最优值的位置
        else
            pbest=  pop(idx_Seek(1),:);
            pbestfitness = fun_w(Distance, pop(idx_Seek(1),:),m,BeaconAmount,Beacon,hop1);
            for j = 2:smp
                for d = 1:para2chang_no
                    Copypop(j,para2change(d)) = (1+Sign*srd)*pop(idx_Seek(i),para2change(d));  %初始种群
                end
                for d = 1:nDIM
                    Copypop(j,:) = min(popmax,max(popmin,Copypop(j,:)));
                end
                Copyfitness(:,j)=fun_w(Distance,Copypop(i,:),m,BeaconAmount,Beacon,hop1);
                %                 Copyfitness(j) = fhd(Copypop(j,:));
                if Copyfitness(:,j)> Max
                    Max = Copyfitness(:,j);
                end
                if Copyfitness(:,j) <   pbestfitness
                    pbest =  Copypop(j,:);
                    pbestfitness  = Copyfitness(:,j);
                    g=i;
                end
            end  
        end
        range = Max - pbestfitness;
        prob = zeros(smp,1);
        for i = 1:smp
            prob(i) = ( Max -Copyfitness(:,j) )/range;
        end
        [~,Mark] = max(prob);
        factor = sum(prob);
        prob = cumsum(prob/factor);
        toss = rand();
        idx = find( toss<prob );
        if ~isempty(idx)
            choice = idx(1);
        else
            choice = Mark;
            I=Copypop(choice,:);
            fitness=Copyfitness(choice);
            pop(i,:)= Copypop(choice,:);
%             if pbestfitness < Gbest
%                 GbestPosition  = pbest;
%                 Gbest =pbestfitness;
%             end
             if pbestfitness < Gbest
            mu = updateMuPV(pop(i,:),GbestPosition,mu,n,1);
            sicma = updateSicmaPV(pop(i,:),GbestPosition,mu,sicma,n,1);
            Gbest = pbestfitness;
            GbestPosition= pop(i,:);
            
            pop(idx_Seek,:)= Up*generateIndividualR(mu,sicma);
        end
        end
        for m1 = 1:size(idx_Trace,2)
            factor_w = zeros(1,nDIM);
            factor_c = zeros(1,nDIM);
            %------------------------ Adaptive Parameters ----------------------%
            w=0.6;
            for i = 1:nDIM
                
                factor_w(i) = w + ( nDIM - i )/( 2*nDIM );
                factor_c(i) = c - ( nDIM - i )/( 2*nDIM );
            end
            %-------------------------- updata velocity ------------------------%
            V(idx_Trace(m1),:) = factor_w(i)*V(idx_Trace(m1),:)+rand()* factor_c(i)*(gbest-pop(idx_Trace(m1),:));
            for d = 1:nDIM
                V(idx_Trace(m1),:)=min(VelMax,max(VelMin,V(idx_Trace(m1),d)));
            end
            %-------------------------- updata location ------------------------%
            pop(idx_Trace(m1),:) = pop(idx_Trace(m1),:)+V(idx_Trace(m1),:);%更新位置公式
            for d = 1:nDIM
                pop(idx_Trace(m1),:) = min(popmax,max(popmin,pop(idx_Trace(m1),d)));
            end
            %         fitness(:,idx_Trace(m)) =fhd(pop(idx_Trace(m),:));
            fitness(:,idx_Trace(m1))=fun_w(Distance,pop(idx_Trace(m1),:),m,BeaconAmount,Beacon,hop1);
            for i = 1:nPOP
                if fitnessgbest < Gbest
                    Gbest = fitnessgbest;
                    GbestPosition =gbest;
                end
            end
        end
        idx_Trace = randperm(nPOP,n_Trace);
        idx_Seek = setdiff(1:nPOP,idx_Trace);
        
        %------------------------------- The End ----------------------------------%
        T(G) = Gbest;
    end
end
% 1
%figure(varargin{:});
% plot(T(1:50:1000),'r-o','LineWidth',1,'Marker','o','MarkerFaceColor','red');
% hold on;
% legend('CSO');














