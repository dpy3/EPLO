
function [TotalBestPosition , TotalBest,Convergence_curve ] = PSSA(fhd,dim,pop,M,c,d,varargin)
        
   P_percent =0.2;    % The population size of producers accounts for "P_percent" percent of the total population size     发现者占百分之20，加入者占820，比重不变  

%总种群中有一部分是producers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pNum = round( pop *  P_percent );    % The population size of the producers 取整  
lb= c.*ones( 1,dim );    % Lower limit/bounds/     a vector c，d代表上下界
ub= d.*ones( 1,dim );    % Upper limit/bounds/     a vector
%Initialization
groups = 4;
for g = 1:groups
for i = 1 : pop    
   group(g).x( i, : ) = lb + (ub - lb) .* rand( 1, dim ); 
end %固定种群内每个变量在上下界内，求解对应的适应值
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

    if( group(g).fitnesspbest( sortIndex( b(j) ) )>(group(g).bestfitness) )

        group(g).x( sortIndex( b(j) ), : )=group(g).gbest+(randn(1,dim)).*(abs(( group(g).pbest( sortIndex( b(j) ), : ) -group(g).gbest)));

        else

        group(g).x( sortIndex( b(j) ), : ) =group(g).pbest( sortIndex( b(j) ), : )+(2*rand(1)-1)*(abs(group(g).pbest( sortIndex( b(j) ), : )-worse))/ ( group(g).fitnesspbest( sortIndex( b(j) ) )-fmax+1e-50);

     end
        group(g).x( sortIndex(b(j) ), : ) = Bounds( group(g).x( sortIndex(b(j) ), : ), lb, ub );
         y=group(g).x( sortIndex( b(j) ), : );
        group(g).fitness(sortIndex( b(j) ))=feval(fhd,y',varargin{:});  
       
    end
  % fit =feval(fhd,x',varargin{:});
    for i = 1 : pop 
        if ( group(g).fitness( i ) < group(g).fitnesspbest( i ) )
            group(g).fitnesspbest( i ) = group(g).fitness( i );
            group(g).pbest( i, : ) = group(g).x( i, : );
        end
        
        if( group(g).fitnesspbest( i ) < group(g).bestfitness )
           group(g).bestfitness= group(g).fitnesspbest( i );
            group(g).gbest = group(g).pbest( i, : );
         
        end
    end
  
           if group(g).bestfitness <TotalBest
            TotalBest = group(g).bestfitness;
             TotalBestPosition = group(g).gbest;
           end
    
    
    end
    Convergence_curve(t)=TotalBest;%fMin=totalbest
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

%---------------------------------------------------------------------------------------------------------------------------
