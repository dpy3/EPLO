function [ Cat,Best ] =SeekMode_CCSO( cat,opts,fhd,varargin )

%------------------------ Parameters Setting -----------------------%
% Up = 100;
% n=1000;


smp = opts.smp;
srd = opts.srd;
spc = rand();
% RangeMin = opts.RangeMin;
% RangeMax = opts.RangeMax;
% nDim = opts.dim;
nDim = size(cat.Posi,1);
% g = bestindex;

% mu = zeros(1,NM);          %mean
% sicma = 10*ones(1,NM);     %standard deviation
% cat.Posi= Up*generateIndividualR(mu,sicma);
if spc<0.5
    flag = 0;
else
    flag = 1;
end
popmin=opts.RangeMin;
popmax=opts.RangeMax;
%  Copypop(j,:) = min(popmax,max(popmin,Copypop(j,:)));
Max = -5;

%-------------------------------------------------------------------%
catCopy = repmat(cat,smp,1);
Sign = rand(smp,nDim);
Sign( Sign>=0.5 ) = 1;
Sign( Sign<0.5 ) = -1;
val = srd.*abs(cat.Posi);
if flag == 0
    %     pbest.Posi = zeros(1,nDim);
    
    pbest.Cost = inf;
    for i = 1:smp
        
        catCopy(i).Posi = cat.Posi + Sign(i,:).*val;
        catCopy(i).Cost = feval(fhd,( catCopy(i).Posi )',varargin{:});
%         catCopy(i).Posi = min(popmax,max(popmin,catCopy(i).Posi));
        if catCopy(i).Cost> Max
            Max = catCopy(i).Cost;
        end
        
        if catCopy(i).Cost < pbest.Cost
            pbest.Posi = catCopy(i).Posi;
            pbest.Cost = catCopy(i).Cost;
            g=i;
        end
    end
else
    pbest.Posi = cat.Posi;
     pbest.Cost =feval(fhd,(cat.Posi )',varargin{:});
    
    for i = 2:smp
        catCopy(i).Posi = cat.Posi + Sign(i,:).*val;
    catCopy(i).Cost = feval(fhd,( catCopy(i).Posi )',varargin{:});
%         catCopy(i).Posi = min(popmax,max(popmin,catCopy(i).Posi));
        if catCopy(i).Cost> Max
            Max = catCopy(i).Cost;
        end
        
        if catCopy(i).Cost < pbest.Cost
            pbest.Posi = catCopy(i).Posi;
            pbest.Cost = catCopy(i).Cost;
            g=i;
            
        end
    end
end
Best = pbest;
range = Max - pbest.Cost;
prob = zeros(smp,1);

for i = 1:smp
    prob(i) = ( Max - catCopy(i).Cost )/range;
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
end

Cat = catCopy(choice);

end

