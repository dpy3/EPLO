

function [TotalBestPosition , TotalBest,Convergence_curve ] = PCSSA1(fhd,dim,pop,M,c,d,varargin)
        a=1;%levy飞行步长控制因子
   P_percent =0.2;    % The population size of producers accounts for "P_percent" percent of the total population size     发现者占百分之20，加入者占820，比重不变  

%总种群中有一部分是producers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lamda=10;
pNum = round( pop *  P_percent );    % The population size of the producers 取整  
lb= c.*ones( 1,dim );    % Lower limit/bounds/     a vector c，d代表上下界
ub= d.*ones( 1,dim );    % Upper limit/bounds/     a vector
%Initialization
groups = 4;
group = repmat(struct('mu',{},'sigma',{}),1,groups);%将这个结构复制一行groups列
for g = 1:groups
    group(g).mu=zeros(1,d);
    group(g).sicma=lamda*ones(1,d);
for i = 1 : pop    
   group(g).x( i, : ) = generateCDFInv(rand,group(g).mu(i),group(g).sicma(i)); 
end %固定种群内每个变量在上下界内，求解对应的适应值
group(g).x = group(g).x*((ub-lb)/2)+lb;
group(g).fitness = feval(fhd,group(g).x',varargin{:});

    [group(g).bestfitness,group(g).bestindex] = min(group(g).fitness);
    group(g).pbest = group(g).x;    %个体最佳
    group(g).gbest = group(g).x(group(g).bestindex,:);   %全局最佳
    group(g).fitnesspbest = group(g).fitness;%个体最佳适应度值
    group(g).fitnessgbest = group(g).bestfitness;%全局最佳适应度值
end
  
TotalBest = group(1).fitnessgbest;
TotalBestPosition = group(1).gbest;

for g = 1:groups
    if group(g).fitnessgbest<TotalBest
        TotalBest = group(g).fitnessgbest;
        TotalBestPosition = group(g).gbest;
    end
end
 
for t = 1 : M  
    for g = 1:groups%迭代开始      
  [ ans, sortIndex ] = sort( group(g).fitnesspbest );% Sort.升序  
  [fmax,B]=max( group(g).fitnesspbest );
   worse= group(g).x(B,:);  %找到最差即所有适应值中的最大值        
   r2=rand(1);
if(r2<0.8)
    for i = 1 : pNum                                                   % Equation (3)
         r1=rand(1);
        group(g).x( sortIndex( i ), : ) = group(g).pbest( sortIndex( i ), : )*exp(-(i)/(r1*M));
        group(g).x( sortIndex( i ), : ) = Bounds( group(g).x( sortIndex( i ), : ), lb, ub );         
    end
  else
  for i = 1 : pNum          
  group(g).x( sortIndex( i ), : ) = group(g).pbest( sortIndex( i ), : )+randn(1)*ones(1,dim);
  group(g).x( sortIndex( i ), : ) = Bounds( group(g).x( sortIndex( i ), : ), lb, ub );  
  y=group(g).x( sortIndex( i ), : );
  group(g).fitness(sortIndex( i ))=feval(fhd,y',varargin{:});  
  end   
end
  %fit = feval(fhd,x',varargin{:});  
 [ fMMin, bestII ] = min( group(g).fitness );      
  bestXX = group(g).x( bestII, : );            


   for i = ( pNum + 1 ) : pop                     % Equation (4)
     
         A=floor(rand(1,dim)*2)*2-1;
         
          if( i>(pop/2))
           group(g).x( sortIndex(i ), : )=randn(1)*exp((worse-group(g).pbest( sortIndex( i ), : ))/(i)^2);
          else
       group(g).x( sortIndex( i ), : )=bestXX+(abs(( group(g).pbest( sortIndex( i ), : )-bestXX)))*(A'*(A*A')^(-1))*ones(1,dim);  

         end  
        group(g).x( sortIndex( i ), : ) = Bounds( group(g).x( sortIndex( i ), : ), lb, ub );
  y=group(g).x( sortIndex( i ), : );
  group(g).fitness(sortIndex( i ))=feval(fhd,y',varargin{:});  
        
   end
        % fit = feval(fhd,x',varargin{:});  
  c=randperm(numel(sortIndex));
   b=sortIndex(c(1:20));
    for j =  1  : length(b)      % Equation (5)

    if( group(g).fitnesspbest( sortIndex( b(j) ) )>(group(g).fitnessgbest) )

        group(g).x( sortIndex( b(j) ), : )=group(g).gbest+(randn(1,dim)).*(abs(( group(g).pbest( sortIndex( b(j) ), : ) -group(g).gbest)));

        else

        group(g).x( sortIndex( b(j) ), : ) =group(g).pbest( sortIndex( b(j) ), : )+(2*rand(1)-1)*(abs(group(g).pbest( sortIndex( b(j) ), : )-worse))/ ( group(g).fitnesspbest( sortIndex( b(j) ) )-fmax+1e-50);

     end
        group(g).x( sortIndex(b(j) ), : ) = Bounds( group(g).x( sortIndex(b(j) ), : ), lb, ub );
         y=group(g).x( sortIndex( b(j) ), : );
        group(g).fitness(sortIndex( b(j) ))=feval(fhd,y',varargin{:});  
       
    end
    
    winner=group(g).x;
    loser = group(g).pbest;
 if ( group(g).fitness( i ) < group(g).fitnesspbest( i ) )
     winner=group(g).pbest;
     loser = group(g).x;
 end
       munew = group(g).mu;
       group(g).mu = updateMuPV(winner,loser,munew,pop,d);
       group(g).sicma = updateSicmaPV(winner,loser,munew,group(g).sicma,pop,d); 
  
  % fit =feval(fhd,x',varargin{:});
    for i = 1 : pop 
        if ( group(g).fitness( i ) < group(g).fitnesspbest( i ) )
            group(g).fitnesspbest( i ) = group(g).fitness( i );
            group(g).pbest( i, : ) = group(g).x( i, : );
        end
        
   
        if( group(g).fitnesspbest( i ) < group(g).fitnessgbest )
           group(g).fitnessgbest= group(g).fitnesspbest( i );
            group(g).gbest = group(g).pbest( i, : );
         
        end
    end
    
           if group(g).fitnessgbest <TotalBest
            TotalBest = group(g).fitnessgbest;
             TotalBestPosition = group(g).gbest;
           end 
         %组内交流策略,最好的
         if mod(t,50)==0
         [ ans1, sortIndex1 ] = sort(group(g).fitnesspbest);    
         group(g).fitnesspbest(sortIndex1(pop))=group(g).fitnesspbest(1);
         group(g).pbest(sortIndex1(pop), : )=group(g).pbest(1, : );
         end
           
    end

    %组间交流策略，除了最优组，其他组levy飞行进行更新
     for i=1:groups
       if group(i).fitnessgbest~=TotalBest
        gbest1=group(i).gbest+a*levy(1,dim,1.5);
         fitnessgbest1=feval(fhd,gbest1',varargin{:});
           if fitnessgbest1<group(i).fitnessgbest
             group(i).fitnessgbest=fitnessgbest1;
           end
           if group(i).fitnessgbest<TotalBest
             TotalBest = group(i).fitnessgbest;
           end
       end
     end
% for i=1:groups
%     a(i)=group(i).fitnessgbest;
% end
%       [ ans1, sortIndex1 ] = sort(a);
%       group(sortIndex1(groups)).fitnessgbest=group(sortIndex1(1)).fitnessgbest;
    
    Convergence_curve(t)=TotalBest;%fMin=totalbest
end
end
function samplerand = generateCDFInv(r,mu,sigma)
erfA = erf((mu+1)/(sqrt(2)*sigma));
erfB = erf((mu-1)/(sqrt(2)*sigma));
samplerand = erfinv(-erfA-r*erfB+r*erfA)*sigma*sqrt(2)+mu;
end
function mmu =updateMuPV(win,lost,mu,Np,dim) %update meanVector belong [-1,1];
mmu=mu;
for k=1:dim
    dm =(1/Np)*(win(k)-lost(k));
%     mmu(k)=mu(k)+dm;
    if (abs(mu(k)+dm)<=1)
        mmu(k)=mu(k)+dm;
    end
end
end
function ssicma =updateSicmaPV(win,los,mu,sicma,Np,dim) 
sicma2=sicma.^2;
ssicma2=sicma2;
mmu=mu;
for k=1:dim
    dm   =(1/Np)*(win(k)-los(k));
    mmu(k)=mu(k)+dm;
    A=mu(k).^2;
    B=mmu(k).^2;
    C=(1/Np)*(win(k).^2-los(k).^2);
    dsicma2=A-B+C;
    if abs(dsicma2)<sicma2(k)
        ssicma2(k)=sicma2(k)+dsicma2;
    else
        ssicma2(k)=sicma2(k);
    end
end
ssicma=sqrt(ssicma2);
end

% Application of simple limits/bounds
function s = Bounds( s, Lb, Ub)
  % Apply the lower bound vector
  temp = s;
  I = temp < Lb;
  temp(I) = Lb(I);
  
  % Apply the upper bound vector 
  J = temp > Ub;
  temp(J) = Ub(J);
  % Update this new move 
  s = temp;
end
%---------------------------------------------------------------------------------------------------------------------------
