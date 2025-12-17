function [Destination_fitness,Convergence_curve]=pcSCA_s1(fhd,dim,N,Max_iteration,lb,ub,fun_no)

% virtual population size
Np=N;
% the dimension of question
Nd=dim;
count=1;
groups = 6;%divide in two groups
disp('parallel compact SCA is optimizing your problem');

if size(ub,2)==1
    Lb=lb*ones(1,Nd);
    Ub=ub*ones(1,Nd);
else 
    Lb=lb;
    Ub=ub;
end

%Initialize the set of random solutions
for g=1:groups
    group(g).mu = zeros(1,Nd);
    group(g).sicma = 10*ones(1,Nd);

    group(g).fmin = inf;
    group(g).best_position = Ub;
end


Destination_fitness=group(1).fmin;
Destination_position=group(1).best_position;
count = 0;
% Convergence_curve(count) = Destination_fitness;
%Main loop
for t=2:Max_iteration
    % Eq. (3.4)
    a = 2;
    r1=a-t*((a)/Max_iteration); % r1 decreases linearly from a to 0
    % Update the position of solutions with respect to destination
    for g=1:groups

%         for x=1:Np/groups

            agent=zeros(1,Nd);
            for i=1:Nd
                agent(i)=generateCDFInv(rand,group(g).mu(i),group(g).sicma(i));
                agent(i) = agent(i)*((Ub(i)-Lb(i))/2) + ((Ub(i)+Lb(i))/2);
            end

            for i=1:Nd% in i-th solution
                % Update r2, r3, and r4 for Eq. (3.3)
                r2=(2*pi)*rand();
                r3=2*rand;
                r4=rand();
                % Eq. (3.3)
                if r4<0.5
                    % Eq. (3.1) 
                    agentsca(i)= agent(i)+(r1*sin(r2)*abs(r3*group(g).best_position(i)-agent(i)));
                else
                    % Eq. (3.2)
                    agentsca(i)= agent(i)+(r1*cos(r2)*abs(r3*group(g).best_position(i)-agent(i)));
                end
            end

            agentsca = simplebounds(agentsca,Lb,Ub);
            [winner,loser,~]=competetwo(agent,agentsca,fhd,fun_no);
            % Update PV
            for i=1:Nd

                winner(i) = (winner(i)-(Ub(i)+Lb(i))/2)/((Ub(i)-Lb(i))/2);
                loser(i) = (loser(i)-(Ub(i)+Lb(i))/2)/((Ub(i)-Lb(i))/2);
                mut = group(g).mu(i);
                group(g).mu(i) = mut + (1/Np)*(winner(i)-loser(i));
                temp = group(g).sicma(i)^2+mut^2-group(g).mu(i)^2+(1/Np)*(winner(i)^2-loser(i)^2);
                if temp>0
                    group(g).sicma(i)=sqrt(temp);
                else
                    group(g).sicma(i)=10;
                end
            end

            winner=change_interval(winner,Lb,Ub,Nd);
            [winner,~,winner_fit]=competetwo(winner,group(g).best_position,fhd,fun_no);
            
            group(g).best_position = winner;
            group(g).fmin = winner_fit;
%         end
    end
    
    for g=1:groups
        if group(g).fmin<Destination_fitness
            Destination_fitness = group(g).fmin;
            Destination_position = group(g).best_position;
        end
    end
    
    if mod(t,50) == 0
        if mod(t,200)==0
            display(['At iteration ', num2str(t), ' the optimum is ', num2str(Destination_fitness)]);
        end
        count = count + 1;
        Convergence_curve(count) = Destination_fitness;
    end

    for g = 1:groups
        sg = mod(g+2,groups);
        if sg == 0
             sg = 1;
        end
        while( mod(sg,groups) ~= g-1)
            r  = rand();
            if r < 0.5
                if group(g).fmin > group(sg).fmin
                    w = sg;
                    l = g;
                else
                    w = g;
                    l = sg;
                end
                group(l).fmin  = group(w).fmin;
                group(l).best_position = group(w).best_position;
                % perturb  (dist(Ub,Lb')/50)*rand.*randn(1,Nd);
                new_rd = group(w).best_position + (dist(Ub,Lb')/50)*rand.*randn(1,Nd);
                new_rd = simplebounds(new_rd,Lb,Ub);
                fit_rd = feval(fhd,new_rd',fun_no);
                if fit_rd < group(w).fmin
                    group(w).fmin = fit_rd;
                    group(w).best_position = new_rd;
                end
            else
                gene(1,:) = group(g).best_position;
                gene(2,:) = Destination_position;
                new_rd = zeros(1,Nd);
                for i = 1:size(gene,2)
                    r = rand();
                    if r < 0.5
                        new_rd(i) = gene(1,i);
                    else
                        new_rd(i) = gene(2,i);
                    end
                end
                fit_rd = feval(fhd,new_rd',fun_no);
                if fit_rd < group(g).fmin
                    group(g).fmin = fit_rd;
                    group(g).best_position = new_rd;
                end
            end
            if sg == 6
                sg = 1;
            else
                sg = sg + 1;
            end
        end
    end
end
end

function samplerand = generateCDFInv(r,mu,sigma)
% mu = 0;
% sigma = 10;
erfA = erf((mu+1)/(sqrt(2)*sigma));
erfB = erf((mu-1)/(sqrt(2)*sigma));
samplerand = erfinv(-erfA-r*erfB+r*erfA)*sigma*sqrt(2)+mu;
end
%compete two individual
function [w,l,winner_fit]=competetwo(x,y,fhd,fun_no)
fx = feval(fhd,x',fun_no);
fy = feval(fhd,y',fun_no);
if fx<fy
    w=x; l=y;
    winner_fit = fx;
else
    w=y; l=x;
    winner_fit = fy;
end
end

function s=simplebounds(s,Lb,Ub)
% Apply the lower bound
ns_tmp=s;
I=ns_tmp<Lb; % 如果比下边界要小
ns_tmp(I)=Lb(I); % 替换为下边界

% Apply the upper bounds
J=ns_tmp>Ub;
ns_tmp(J)=Ub(J);
% Update this new move
s=ns_tmp;
end


function s=change_interval(s,Lb,Ub,Nd)
for i=1:Nd
    s(i) = s(i)*((Ub(i)-Lb(i))/2) + ((Ub(i)+Lb(i))/2);
end
end