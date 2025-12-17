function [Best_Fitness_BKA,Best_Pos_BKA,Convergence_curve]=NBKA(pop,T,lb,ub,dim,fobj)
%% ----------------Initialize the locations of Blue Sheep------------------%

p=0.9;
r=rand;
index = 1;
XPos=ninitialization(pop,dim,ub,lb);% Initial population
for i =1:pop
    XFit(i)=fobj(XPos(i,:));
end
Convergence_curve=zeros(1,T);

%% -------------------Start iteration------------------------------------%
for t=1:T
    [~,sorted_indexes]=sort(XFit);
    XLeader_Pos=XPos(sorted_indexes(1),:);
    XLeader_Fit = XFit(sorted_indexes(1));
   
%% -------------------Attacking behavior-------------------%

    for i=1:pop
        n=0.05*exp(-2*(t/T)^2);
        if p<r
            XPosNew(i,:)=XPos(i,:)+n.*(1+sin(r))*XPos(i,:);
        else
            XPosNew(i,:)= XPos(i,:).*(n*(2*rand(1,dim)-1)+1);
        end
        XPosNew(i,:) = max(XPosNew(i,:),lb);
        XPosNew(i,:) = min(XPosNew(i,:),ub);%%Boundary checking
%% ------------ Select the optimal fitness value--------------
        %XFit_New(i)=fobj(XPosNew(i,:));
        %if(XFit_New(i)<XFit(i))
            %XPos(i,:) = XPosNew(i,:);
            %XFit(i) = XFit_New(i);
        %end

        %% --------------  透镜反向学习策略找最优适应度值---------%

        XFit_New(i)=fobj(XPosNew(i,:));
        if(XFit_New(i)<XFit(i))
            XPos(i,:) = XPosNew(i,:);
            XFit(i) = XFit_New(i);
        end
        %for i=1:pop
            %k=(1+(t/T)^0.5)^10;
            %XPosNew(i,:) = (ub+lb)/2+(ub+lb)/(2*k)-XPos(i,:)/k;
        %end
        %XPosNew(i,:) = max(XPosNew(i,:),lb);
        %XPosNew(i,:) = min(XPosNew(i,:),ub);
        %XFit_New(i)=fobj(XPosNew(i,:));
        %if(XFit_New(i)<XFit(i))
            %XPos(i,:) = XPosNew(i,:);
            %XFit(i) = XFit_New(i);
        %end
    %end
        %% -------------------Migration behavior-------------------%
        m=2*sin(r+pi/2);
        s = randi([1,30],1);
        r_XFitness=XFit(s);
        ori_value = rand(1,dim);cauchy_value = tan((ori_value-0.5)*pi);
        if XFit(i)< r_XFitness
            XPosNew(i,:)=XPos(i,:)+cauchy_value(:,dim).* (XPos(i,:)-XLeader_Pos);
        else
            XPosNew(i,:)=XPos(i,:)+cauchy_value(:,dim).* (XLeader_Pos-m.*XPos(i,:));
        end
        %---------------------------------------变异策略---------------------------------------
        %----------------------------------------------------------------------------------------
        %  变异策略 加入 位置更新 之后（当然也可以加入到其他公式之后，自行选择）
        % 与原算法仅 多了 下面一行
        p=0.5; % 选择概率
        if rand>p
            mu=XLeader_Pos; % 以最优解 作为高斯函数的均值
            sigma=(ub-lb)./6; % 定义的一个相关参数，正态分布的标准差
            r=normrnd(mu,sigma);  % % 高斯函数生成数值
            XPosNew(i,:)=r.*XPosNew(i,:); % 变异后的个体
        else
            XPosNew(i,:)=XPosNew(i,:);
        end
        %边界检查，防止超出 变量范围
        % Flag4ub=XPosNew(i,:)>ub;
        % Flag4lb=XPosNew(i,:)<lb;
        % mx=(mx.*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        % p=0.6; % 选择概率
        % F=rand; % 缩放因子,rand函数随机生成
        % npop = size(XPos,1); % 种群数
        % if rand>p
        %     XPosNew(i,:)=XPosNew(i,:)+F*(XLeader_Pos- XPosNew(i,:))+F*(XPos(randi(npop),:)-XPos(randi(npop),:));
        % else
        %     XPosNew(i,:)=XLeader_Pos+F*(XPos(randi(npop),:)-XPos(randi(npop),:));
        % end
        % 边界检查，防止超出 变量范围
        % Flag4ub=mx>ub;
        % Flag4lb=mx<lb;
        % mx=(mx.*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb; 
        %---------------------------------------变异策略---------------------------------------
        %----------------------------------------------------------------------------------------
         XPosNew(i,:) = max(XPosNew(i,:),lb);
         XPosNew(i,:) = min(XPosNew(i,:),ub); %%Boundary checking
   
%% --------------  Select the optimal fitness value---------%

        XFit_New(i)=fobj(XPosNew(i,:));
        if(XFit_New(i)<XFit(i))
            XPos(i,:) = XPosNew(i,:);
            XFit(i) = XFit_New(i);
        end

    %% -------Update the optimal Black-winged Kite----------%

    if(XFit<XLeader_Fit)
        Best_Fitness_BKA=XFit(i);
        Best_Pos_BKA=XPos(i,:);
    else
        Best_Fitness_BKA=XLeader_Fit;
        Best_Pos_BKA=XLeader_Pos;
    end
    Convergence_curve(t)=Best_Fitness_BKA;
end
end
