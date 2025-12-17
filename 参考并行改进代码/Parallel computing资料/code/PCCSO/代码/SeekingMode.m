function [ Cat] = SeekingMode( cat,fhd,opts,func_num,nDim,spc,CDC )
%------------------------ Parameters Setting -----------------------%
smp = opts.smp;
srd = opts.srd;
% RangeMin = opts.RangeMin;
% RangeMax = opts.RangeMax;
% nDim = size(cat.Posi,1);
if spc<0.5
    flag = 1;%候选解包含cat自身
else
    flag = 0;
end

Max = -5;

%-------------------------------------------------------------------%
catCopy = repmat(cat,smp,1);
% catCopy.Cost=[smp,1];
% Sign = rand(smp,nDim);
% Sign( Sign>=0.5 ) = 1;
% Sign( Sign<0.5 ) = -1;
Pbest.Posi = zeros(1,nDim);
Pbest.Cost = inf;

count=CDC*nDim;
% val = srd.*abs(cat.Posi(:,sq));
if flag == 0 %不包含
    for i = 1:smp
        sq=randperm(nDim,count);
        for j=1:count
            temp=srd*catCopy(i).Posi(sq(j));
            if rand()<0.5
                temp=temp*(-1);
            end
            catCopy(i).Posi(sq(k))=catCopy(i).Posi(sq(k))+temp;
        end
        catCopy(i).Cost = fhd( catCopy(i).Posi',func_num );
        %求copycat.cost的最大、最小值
        if catCopy(i).Cost> Max
            Max = catCopy(i).Cost;
        end
        
        if catCopy(i).Cost < Pbest.Cost
            Pbest.Posi = catCopy(i).Posi;
            Pbest.Cost = catCopy(i).Cost;
        end
    end
else
    %     Pbest.Posi = cat.Posi;
    %     Pbest.Cost = fhd( cat.Posi',func_num );
    %     tem.Posi=repmat(cat.Posi,(smp-1),1);
    %     catCopy.Posi(1,:)=cat.Posi;
    %     catCopy.Posi(2:smp,:)=tem.Posi;
    
    for i = 2:smp
        sq=randperm(nDim,count);
        for j=1:count
            temp=srd*catCopy(i).Posi(sq(j));
            if rand()<0.5
                temp=temp*(-1);
            end
            catCopy(i).Posi(sq(j))=catCopy(i).Posi(sq(j))+temp;
        end
    end
    
    for i=1:smp
        catCopy(i).Cost = fhd( catCopy(i).Posi',func_num );
        
        if catCopy(i).Cost> Max
            Max = catCopy(i).Cost;
        end
        
        if catCopy(i).Cost < Pbest.Cost
            Pbest.Posi = catCopy(i).Posi;
            Pbest.Cost = catCopy(i).Cost;
        end
    end
    
    % end
    %     Best = Pbest;
    range = Max - Pbest.Cost;
    prob = zeros(smp,1);
    
    %     for i = 1:smp
    %         prob(i) = abs( catCopy(i).Cost-Max )/range;   %算copycat的Pi，轮盘赌选择并替换cat(i)
    %     end
    for i=1:smp
        if (Max-Pbest.Cost==0)
            prob(i)=1;
        else
            prob(i)=abs(catCopy(i).Cost-Max)/range;%If the goal is to find the near maximum solution, FSb=FSmin, otherwise FSb=FSmax.
        end
    end
    d_tmp=rand();
    for i=1:smp
        if d_tmp<=prob(i);
            cat.Posi=catCopy(i).Posi;
            cat.Cost=fhd( cat.Posi',func_num );
        end
        break;
    end
    % [~,Mark] = max(prob);
    % factor = sum(prob);
    % prob = cumsum(prob/factor);
    % toss = rand();
    % idx = find(toss<prob); % p>toss的数
    % if ~isempty(idx)
    %     choice = idx(1);%p>toss的第一个数
    % else
    %     choice = Mark;
    % end
    % Best=cat.Cost;
    % Cat = catCopy(choice);
    Cat=cat;
end

