function ne_cDE(maxx,minx,dim,fun_num,f,cr)
time_start=cputime;% Procedure start time
global max_x min_x initial_flag
d=dim;% Number of dimensions
F=f;% Scale factor
Cr=cr;% Crossover probability
Np=2*dim;% Size of population
yita=10;
max_testnum=10;
max_generation = 5000*dim;
max_x=maxx;% x maximum
min_x=minx;% x minimum
bestvalue= zeros(max_testnum,max_generation);
bestsolution=zeros(max_testnum,d);
for testnum=1:max_testnum
    initial_flag=0;
    cur_generation = 0;
    % Initialize PV(mu,sigma)
    mu=zeros(1,d);
    sigma=ones(1,d);
    elite=generateIndividualR(mu,sigma);
    counter=0;
    while cur_generation<max_generation
        cur_generation = cur_generation +1;
        xr=generateIndividualR(mu,sigma);
        xs=generateIndividualR(mu,sigma);
        xt=generateIndividualR(mu,sigma);
        % Mutation
        xoff=xt+(xr-xs)*F;
        % Crossover
        %         xoff(abs(xoff)>1)=-1+2*rand;
        for i=1:d
            %             if abs(xoff(i))>1
            %                 xoff(i)=generateIndividualR(mu(i),sigma(i));
            %             end
            if rand>Cr
                xoff(i)=elite(i);
            end
        end
        % Elite selection
        [winner,loser]=compete(xoff,elite,fun_num);
        if elite==winner
            counter=counter+1;
        elseif counter>yita
            elite=xoff;
            counter=0;
        end
        bestvalue(testnum,cur_generation)=fitness((elite+1)*(max_x-min_x)/2+min_x,fun_num);
        %Update PV
        tempmu=mu;
        mu = tempmu+ (winner-loser)/Np;
        for i=1:d
            tempsigma=sigma(i)^2+tempmu(i)^2-mu(i)^2+(winner(i)^2-loser(i)^2)/Np;
            sigma(i)=sqrt(max(0,tempsigma));
        end
        fprintf('The %05.0fth %05.0fth iteration has been completed,The optimal value is %04.15f \n',testnum,cur_generation,bestvalue(testnum,cur_generation));
    end
    bestsolution(testnum,:)=elite;
end
avg_bestvalue=sum(bestvalue)/max_testnum;
StandardDeviation=sqrt(sum((bestvalue(:,max_generation)-avg_bestvalue(max_generation)).^2)/max_testnum);
disp(elite);
disp((elite+1)*(max_x-min_x)/2+min_x);
disp(avg_bestvalue(max_generation));
disp(StandardDeviation);
xlswrite('10ne_cDEavg+std.xlsx',avg_bestvalue(max_generation),1, strcat('A',num2str(fun_num)));
xlswrite('10ne_cDEavg+std.xlsx',StandardDeviation',1,strcat('B',num2str(fun_num)));
% xlswrite('avg_bestvalue.xlsx',avg_bestvalue, num2str(fun_num));
xlswrite('10ne_cDEbestsolution.xlsx',bestsolution, num2str(fun_num));
xlswrite('10ne_cDEbestvalue.xlsx',bestvalue(:,max_generation)', num2str(fun_num));
% plot(avg_bestvalue,'-g');
fprintf('The time consumed by cDE is:%fs\n',cputime - time_start);
end