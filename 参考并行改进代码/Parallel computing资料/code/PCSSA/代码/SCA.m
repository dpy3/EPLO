
function [Destination_fitness,Destination_position,Convergence_curve]=SCA(fhd,d,N,Max_iteration,lb,ub,varargin)

% lb=100;
% ub=-100;

%display('SCA is optimizing your problem');
X=initialization(N,d,ub,lb);    %初始化生成X，16行30列的矩阵·
Destination_position=zeros(1,d);%目标位置
Destination_fitness=inf;%适应函数值
Convergence_curve=zeros(1,Max_iteration);%目标曲线
Objective_values = zeros(1,size(X,1));%存放sca前的适应函数值
for i=1:size(X,1)
    Objective_values(1,i)=feval(fhd,X(i,:)',varargin{:});%在某个函数对应的适应值
    if i==1%初始化第一组的X，然后比较进行更新
        Destination_position=X(i,:);
        Destination_fitness=Objective_values(1,i);
    elseif Objective_values(1,i)<Destination_fitness%判断是否要更新
        Destination_position=X(i,:);
        Destination_fitness=Objective_values(1,i);
    end
    % All_objective_values(1,i)=Objective_values(1,i);
end
Convergence_curve(1) = Destination_fitness;
t=2;
while t<=Max_iteration
    a = 2;
    r1=a-t*((a)/Max_iteration);
    for i=1:size(X,1)
        for j=1:size(X,2)
            r2=(2*pi)*rand();
            r3=2*rand;
            r4=rand();
             if r4<0.5
                X(i,j)= X(i,j)+(r1*sin(r2)*abs(r3*Destination_position(j)-X(i,j)));
            else
                 X(i,j)= X(i,j)+(r1*cos(r2)*abs(r3*Destination_position(j)-X(i,j)));
            end
        end
    end%sca算法之后生成的X
    for i=1:size(X,1)
        Flag4ub=X(i,:)>ub;
        Flag4lb=X(i,:)<lb;
        X(i,:)=(X(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        Objective_values(1,i)=feval(fhd,X(i,:)',varargin{:});%根据sca后生成的X求出在某个函数内的适应值
        if Objective_values(1,i)<Destination_fitness %判断是否要更新
            Destination_position=X(i,:);
            Destination_fitness=Objective_values(1,i);
        end
    end
    Convergence_curve(t)=Destination_fitness;%在t次迭代处的曲线值
%     if mod(t,50)==0 %迭代50次处理一次
%         display(['At iteration ', num2str(t), ' the optimum is ', num2str(Destination_fitness)]);
%     end
    t=t+1;
end