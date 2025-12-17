function DE(maxx,minx,dim,fun_num,f,cr)
time_start = cputime;
global max_x min_x initial_flag
d = dim;%所求问题的维数
F =f;
Cr = cr;%交叉概率
Np = 2*dim ;
max_testnum=30;
max_generation = 5000*dim;
max_x=maxx;% x maximum
min_x=minx;% x minimum
bestvalue = zeros(max_testnum,max_generation); %各次实验每一代的最优值
bestsolution = zeros(max_testnum,d); %各次实验的最优解
for testnum=1:max_testnum
    initial_flag=0;
    cur_generation= 0; %初始化代数
    %产生初始种群
    X0 = (max_x-min_x)*rand(Np,d) + min_x;  %产生Np个D维向量
    XG = X0;
    while cur_generation <= max_generation
        cur_generation = cur_generation +1;
        XG_next = zeros(Np,d);%最终后代
        XG_next_1= zeros(Np,d);
        XG_next_2 = zeros(Np,d);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%---变异操作---%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1:Np
            %产生r,s,t三个不同的数
            randx = randperm(Np);
            r = randx(1);
            s = randx(2);
            t = randx(3);
            %要保证与i不同
            if r == i
                r = randx(4);
            elseif s == i
                s = randx(4);
            elseif t == i
                t = randx(4);
            end
            
            %             suanzi = exp(1-Gm/(Gm + 1-G));
            %             F = F0*2.^suanzi;
            %变异的个体来自三个随机父代
            xoff = XG(r,:) + F*(XG(t,:) - XG(s,:));
            for j = 1: d
                if xoff(j) >min_x  && xoff(j) < max_x %防止变异超出边界
                    XG_next_1(i,j) = xoff(j);
                else
                    XG_next_1(i,j) = (max_x - min_x)*rand(1) + min_x;
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%---交叉操作---%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1: Np
            randx = randperm(d);%[1,2,3,...d]的随机序列
            for j = 1: d
                if rand > Cr && randx(1)~= j
                    XG_next_2(i,j) = XG(i,j);
                else
                    XG_next_2(i,j) = XG_next_1(i,j);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%---选择操作---%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i = 1:Np
            XG_next(i,:)=DEcompete(XG_next_2(i,:),XG(i,:),fun_num);
        end
        %找出最小值
        currentbestvalue=zeros(1,Np);
        for i = 1:Np
            currentbestvalue(i) = fitness(XG_next(i,:),fun_num);
        end
        [cur_value_min,pos_min] = min(currentbestvalue);
        %第testnum次实验中第cur_generation代中的目标函数的最小值
        bestvalue(testnum,cur_generation) = cur_value_min;
        XG = XG_next;
        fprintf('The %05.0fth %05.0fth iteration has been completed,The optimal value is %04.15f \n',testnum,cur_generation,bestvalue(testnum,cur_generation));
    end
    %保存每次实验最优的个体
    bestsolution(testnum,:) = XG_next(pos_min,:);
end
avg_bestvalue=sum(bestvalue)/max_testnum;
StandardDeviation=sqrt(sum((bestvalue(:,max_generation)-avg_bestvalue(:,max_generation)).^2)/max_testnum);
best_vector=  bestsolution(max_testnum,:) ;
disp(best_vector);
disp(avg_bestvalue(max_generation));
disp(StandardDeviation);
xlswrite('DEavg+std.xlsx',avg_bestvalue(max_generation),1, strcat('A',num2str(fun_num)));
xlswrite('DEavg+std.xlsx',StandardDeviation',1,strcat('B',num2str(fun_num)));
% xlswrite('avg_bestvalue.xlsx',avg_bestvalue, num2str(fun_num));
xlswrite('DEbestsolution.xlsx',bestsolution, num2str(fun_num));
xlswrite('DEbestvalue.xlsx',bestvalue(:,max_generation)', num2str(fun_num));
% plot(avg_bestvalue,'-g');
fprintf('DE所耗的时间为：%f \n',cputime - time_start);
end