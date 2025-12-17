function [ Cost,Posi] = TracingMode_parallel(  posi,cost,velo,best,opts )
%------------------------ Parameters Setting -----------------------%
c = opts.c;
VelMin = opts.VelMin;
VelMax = opts.VelMax;
nDim = size(posi,1);
r = rand();

%-------------------------------------------------------------------%

%-------------------------- updata velocity ------------------------%
velo = velo + r*c*( best.Posi - posi ) ;
% 限制速度范围
for i = 1:nDim  
    
    if velo(i) < VelMin
        velo(i) = VelMin;
    end
    
    if velo(i) > VelMax
       velo(i) = VelMax;
    end
end
%-------------------------------------------------------------------%

%-------------------------- updata location ------------------------%
posi = posi + velo;
%-------------------------------------------------------------------%
Posi=posi;
Cost=cost;
end

