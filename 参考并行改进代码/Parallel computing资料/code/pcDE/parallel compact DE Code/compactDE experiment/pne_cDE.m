function pne_cDE(maxx,minx,dim,fun_num,f,cr)
time_start=cputime;% Procedure start time
global max_x min_x initial_flag
d=dim;% Number of dimensions
F=f;% Scale factor
Cr=cr;% Crossover probability
Np=2*dim;% Size of population
yita=10;
groups=3;
max_testnum=10;
max_generation = 5000*dim;
max_x=maxx;% x maximum
min_x=minx;% x minimum
bestvalue= zeros(max_testnum,max_generation);
bestsolution=zeros(max_testnum,d);
Group=repmat(struct('mu',{},'sigma',{},'elite',{}),1,groups);
for testnum=1:max_testnum
    initial_flag=0;
    cur_generation=0;
    for i = 1:groups
        % Initialize PV(mu,sigma)
        Group(i).mu =zeros(1,d);
        Group(i).sigma =ones(1,d);
        Group(i).elite=generateIndividualR(Group(i).mu,Group(i).sigma);
    end
    counter=0;
    while cur_generation<max_generation
        cur_generation=cur_generation+1;
        group_min_value=zeros(1,groups);%每个小组的最优值
        for i=1:groups
            xoff=generateIndividual3(Group(i).mu,Group(i).sigma,Group(i).elite,F,Cr);
            [winner,loser]=compete(xoff,Group(i).elite,fun_num);
            if Group(i).elite==winner
                counter=counter+1;
            elseif counter>yita
                Group(i).elite=xoff;
                counter=0;
            end
            tempmu=Group(i).mu;
            Group(i).mu= Group(i).mu + (winner-loser)/Np;
            for j=1:d
                tempsigma=Group(i).sigma(j)^2+tempmu(j)^2-Group(i).mu(j)^2+(winner(j)^2-loser(j)^2)/Np;
                Group(i).sigma(j)=sqrt(max(0,tempsigma));
                %                 if(tempsigma>=0)
                %                     Group(i).sigma(j)=sqrt(tempsigma);
                %                 else
                %                     Group(i).sigma(j)=sqrt(0.0001);
                %                 end
            end
            %         s1=Group(i).mu+s1;
            %         s2=Group(i).sigma+s2;
            %         s3=Group(i).elite+s3;
            group_min_value(i)=fitness((Group(i).elite+1)*(max_x-min_x)/2+min_x,fun_num);
            %         fitness((Group(i).elite+1)*(max_x-min_x)/2+min_x)
        end
        [minx,I]=min(group_min_value);
        if mod(cur_generation,10)==0
            for i=1:groups
                Group(i).mu=Group(I).mu;
                Group(i).sigma=Group(I).sigma;
                Group(i).elite=Group(I).elite;
                %Group(i).elite=s3/groups;
            end
        end
        bestvalue(testnum,cur_generation)=minx;
        fprintf('The %05.0fth %05.0fth iteration has been completed,The optimal value is %04.15f \n',testnum,cur_generation,bestvalue(testnum,cur_generation));
    end
    bestsolution(testnum,:)=Group(I).elite;
end
avg_bestvalue=sum(bestvalue)/max_testnum;
StandardDeviation=sqrt(sum((bestvalue(:,max_generation)-avg_bestvalue(max_generation)).^2)/max_testnum);
disp(Group(I).elite);
disp((Group(I).elite+1)*(max_x-min_x)/2+min_x);
disp(avg_bestvalue(max_generation));
disp(StandardDeviation);
xlswrite('10pne_cDEavg+std.xlsx',avg_bestvalue(max_generation),1, strcat('A',num2str(fun_num)));
xlswrite('10pne_cDEavg+std.xlsx',StandardDeviation',1,strcat('B',num2str(fun_num)));
xlswrite('10pne_cDEbestsolution.xlsx',bestsolution, num2str(fun_num));
xlswrite('10pne_cDEbestvalue.xlsx',bestvalue(:,max_generation)', num2str(fun_num));
plot(avg_bestvalue,'-g');
fprintf('The time consumed by cDE is:%fs\n',cputime - time_start);
end
