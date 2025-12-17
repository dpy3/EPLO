% clear all
% mex cec13_func.cpp -DWINDOWS
clear
fhd=str2func('cec13_func');
func_num=1; 
nDIM = 10;%@
popmax = 100;
popmin = -100;
VelMin =  -0.1*( popmax-popmin );
VelMax =   0.1*( popmax-popmin );
nPOP=160;%pop_size8 = 40;
iter_max = 500;
smp = 40;
srd  = 0.8;
mr = 0.8;
c = 1.05;
empty_cat.Posi  = zeros(nDIM,1);
gBest.Posi      = zeros(nDIM,1);
empty_cat.Velo  = zeros(nDIM,1);
cat   = repmat(empty_cat,nPOP,1);
%----------------------------------- End ----------------------------------%
%-------------------------------- CSO Algorithm ---------------------------%
for i =1:28
    func_num = i;
    for j = 1:30
        i,j
   %[Gbest,T]= CSO2(fhd,nDIM,nPOP,mr,srd,smp,c,iter_max,VelMin,VelMax,popmin,popmax,func_num);
  %[Gbest,T]= CCSO2(fhd,nDIM,nPOP,mr,srd,smp,c,iter_max,VelMin,VelMax,popmin,popmax,func_num);
 [Gbest,T]= PCSO(fhd,nDIM,nPOP,mr,srd,smp,c,iter_max,VelMin,VelMax,popmin,popmax,func_num);
% [Gbest,T]= PCCSO1(fhd,nDIM,nPOP,mr,srd,smp,c,iter_max,VelMin,VelMax,popmin,popmax,func_num);
  %   [Gbest,T]= PCCSO2(fhd,nDIM,nPOP,mr,srd,smp,c,iter_max,VelMin,VelMax,popmin,popmax,func_num);
%    [Gbest,T]= PCCSO3(fhd,nDIM,nPOP,mr,srd,smp,c,iter_max,VelMin,VelMax,popmin,popmax,func_num);
%      [Gbest,T]= PCCSO4(fhd,nDIM,nPOP,mr,srd,smp,c,iter_max,VelMin,VelMax,popmin,popmax,func_num);
     fbest(i,j)=Gbest;
        for t = (iter_max/20):(iter_max/20):iter_max
            a = t/(iter_max/20);
           FV(j,a) =  T(t);
        end 
    end
    for g = 1:20
        fv_mean(i,g) = mean(FV(:,g));
    end
    f_mean(i)=mean(fbest(i,:));
end
