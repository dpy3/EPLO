% function Cat = Adamode( cat,Costfunction1,opts )
function Cat = Adamode( cat,best,opts )
%------------------------ Parameters Setting -----------------------%
c = 1.05;
VelMin = opts.VelMin;
VelMax = opts.VelMax;
nDim = size(cat.Posi,1);%何时对cat.Posi进行了赋值？
r = rand();

%------------- Self-Define -------------%
w = 0.6;
% c = 1.06; 
% c1 = 2.0;
% c2 = 2.0;
% nDim = 2;

% gamma = 0.6;
%---------------------------------------%

%-------------------------------------------------------------------%
factor_w = zeros(1,nDim);
% % factor_c1 = zeros(nDim,1);
% % factor_c2 = zeros(nDim,1);
factor_c = zeros(1,nDim);
%------------------------ Adaptive Parameters ----------------------%
for i = 1:nDim
    factor_w(i) = w + ( nDim - i )/( 2*nDim );
%     factor_c1(i) = c - ( nDim - i )/( 2*nDim );
%     factor_c2(i) = c + ( nDim - i )/( 2*nDim );
    factor_c(i) = c - ( nDim - i )/( 2*nDim );
end
%-------------------------------------------------------------------%

%-------------------------- updata velocity ------------------------%

    cat.Velo =cat.Velo+ r*c.*( best.Posi- cat.Posi);
% cat.Velo = w*cat.Velo+ r*c*( best.Posi- cat.Posi);
%      for d = 1:nDim
%         cat.Velo(:,d)=max(VelMin,min(VelMax,cat.Velo(:,d)));
%     end
    

%-------------------------------------------------------------------%

%-------------------------- updata location ------------------------%
cat.Posi = cat.Posi + cat.Velo;
% for d = 1:nDim
%       cat.Posi=max(VelMin,min(VelMax,cat.Posi));
%     end
%     
% for i = 2:nDim
%     cat.Posi(i) = 0.5*( cat.Posi(i) + cat.Velo(i) ) + gamma*( cat.Posi(i-1) + cat.Velo(i-1) );
% end
%-------------------------------------------------------------------%
Cat = cat;


end

