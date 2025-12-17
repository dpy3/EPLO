clear;
close all;
clc;
func_num=1;
D = 10;
Vmin=-10;
Vmax=10;
popmax = 100;
popmin = -100;
fhd=str2func('cec13_func');
for i =3:28
    func_num = i;
    i
    for j =1:30
  j    
%         Function_name= fun_name{i}; % Name of the test function that can be from F1 to F23 (Table 1,2,3 in the paper)
        % Load details of the selected benchmark function
%         [lb,ub,dim,CostFunction]=Get_Functions_details(Function_name);
        opts.smp = 40;
        opts.srd  = 0.8;
        opts.mr = 0.8;
        opts.RangeMin = -100;
        opts.RangeMax =  100;
        opts.VelMin =  -20;
        opts.VelMax =   20;
        opts.c = 1.05;
        opts.Max_iteration=500;
        opts.Showflag = 1;
        opts.way = 1;
        opts.dim=10;
        opts.N=160;
        [TotalBest, T] = PSO1(opts,fhd,func_num);
        % [TotalBest, T] = PPSO(opts,CostFunction);
        % [TotalBest, T]=GWO(opts.N, opts.Max_iteration,opts.RangeMin,opts.RangeMax,opts.dim,CostFunction);
        %     [TotalBest, T] = CSO(opts,fhd,func_num); 
     %       [TotalBest, T] = CCSO1(opts,fhd,func_num);
   %   [TotalBest, T] = PCSO1(opts,fhd,func_num);
    %  [TotalBest, T] = PCCSO1(opts,fhd,func_num);
        fbest(i,j)=TotalBest;
         I =opts.Max_iteration;
       % I = opts.Max_iteration*opts.N/16;
        for t = (I/20):(I/20):I
            a = t/(I/20);
            FV(j,a) =  T(t);
        end
    end
    for g = 1:20
        fv_mean(i,g) = mean(FV(:,g));
    end
    f_mean(i)=mean(fbest(i,:));
end