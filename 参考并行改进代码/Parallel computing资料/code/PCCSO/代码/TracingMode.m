function Cat  = TracingMode( cat,best,opts )
%------------------------ Parameters Setting -----------------------%
c = opts.c;
VelMin = opts.VelMin;
VelMax = opts.VelMax;
nDim = size(cat.Posi,1);
r = rand();

%-------------------------------------------------------------------%

%-------------------------- updata velocity ------------------------%
cat.Velo = cat.Velo + r*c*( best.Posi - cat.Posi ) ;
% 限制速度范围
for i = 1:nDim  
    
    if cat.Velo(i) < VelMin
        cat.Velo(i) = VelMin;
    end
    
    if cat.Velo(i) > VelMax
        cat.Velo(i) = VelMax;
    end
end
%-------------------------------------------------------------------%

%-------------------------- updata location ------------------------%
cat.Posi = cat.Posi + cat.Velo;
%-------------------------------------------------------------------%
Cat = cat;
end

