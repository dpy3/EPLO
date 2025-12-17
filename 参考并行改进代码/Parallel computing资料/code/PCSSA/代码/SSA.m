

function [fMin , bestX,Convergence_curve ] = SSA(fhd,dim,pop,M,c,d,varargin)
        
   P_percent =0.2;    % The population size of producers accounts for "P_percent" percent of the total population size     发现者占百分之20，加入者占820，比重不变  

%总种群中有一部分是producers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pNum = round( pop *  P_percent );    % The population size of the producers 取整  
lb= c.*ones( 1,dim );    % Lower limit/bounds/     a vector c，d代表上下界
ub= d.*ones( 1,dim );    % Upper limit/bounds/     a vector
%Initialization
for i = 1 : pop    
    x( i, : ) = lb + (ub - lb) .* rand( 1, dim ); 
    y= x( i, : );
    fit(i) =feval(fhd,y',varargin{:}); 
end %固定种群内每个变量在上下界内，求解对应的适应值
  
pFit = fit;                      
pX = x;                            % The individual's best position corresponding to the pFit
[ fMin, bestI ] = min( fit );      % fMin denotes the global optimum fitness value
bestX = x( bestI, : );             % 对应全局最优的位置bestX denotes the global optimum position corresponding to fMin
 % Start updating the solutions.
for t = 1 : M    %迭代开始      
  [ ans, sortIndex ] = sort( pFit );% Sort.升序  
  [fmax,B]=max( pFit );
   worse= x(B,:);  %找到最差即所有适应值中的最大值        
   r2=rand(1);
if(r2<0.8)
    for i = 1 : pNum                                                   % Equation (3)
         r1=rand(1);
        x( sortIndex( i ), : ) = pX( sortIndex( i ), : )*exp(-(i)/(r1*M));
        x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );         
    end
  else
  for i = 1 : pNum          
  x( sortIndex( i ), : ) = pX( sortIndex( i ), : )+randn(1)*ones(1,dim);
  x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );  
  y=x( sortIndex( i ), : );
  fit(sortIndex( i ))=feval(fhd,y',varargin{:});  
  end   
end
  %fit = feval(fhd,x',varargin{:});  
 [ fMMin, bestII ] = min( fit );      
  bestXX = x( bestII, : );            


   for i = ( pNum + 1 ) : pop                     % Equation (4)
     
         A=floor(rand(1,dim)*2)*2-1;
         
          if( i>(pop/2))
           x( sortIndex(i ), : )=randn(1)*exp((worse-pX( sortIndex( i ), : ))/(i)^2);
          else
        x( sortIndex( i ), : )=bestXX+(abs(( pX( sortIndex( i ), : )-bestXX)))*(A'*(A*A')^(-1))*ones(1,dim);  

         end  
        x( sortIndex( i ), : ) = Bounds( x( sortIndex( i ), : ), lb, ub );
  y=x( sortIndex( i ), : );
  fit(sortIndex( i ))=feval(fhd,y',varargin{:});  
        
   end
        % fit = feval(fhd,x',varargin{:});  
  c=randperm(numel(sortIndex));
   b=sortIndex(c(1:20));
    for j =  1  : length(b)      % Equation (5)

    if( pFit( sortIndex( b(j) ) )>(fMin) )

        x( sortIndex( b(j) ), : )=bestX+(randn(1,dim)).*(abs(( pX( sortIndex( b(j) ), : ) -bestX)));

        else

        x( sortIndex( b(j) ), : ) =pX( sortIndex( b(j) ), : )+(2*rand(1)-1)*(abs(pX( sortIndex( b(j) ), : )-worse))/ ( pFit( sortIndex( b(j) ) )-fmax+1e-50);

     end
        x( sortIndex(b(j) ), : ) = Bounds( x( sortIndex(b(j) ), : ), lb, ub );
         y=x( sortIndex( b(j) ), : );
        fit(sortIndex( b(j) ))=feval(fhd,y',varargin{:});  
       
    end
  % fit =feval(fhd,x',varargin{:});
    for i = 1 : pop 
        if ( fit( i ) < pFit( i ) )
            pFit( i ) = fit( i );
            pX( i, : ) = x( i, : );
        end
        
        if( pFit( i ) < fMin )
           fMin= pFit( i );
            bestX = pX( i, : );
         
            
        end
    end
  
    Convergence_curve(t)=fMin;
  
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
