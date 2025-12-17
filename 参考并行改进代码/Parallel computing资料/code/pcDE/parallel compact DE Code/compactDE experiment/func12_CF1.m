function fit=func12_CF1(x)
global initial_flag
persistent  fun_num func o sigma lamda bias M
if initial_flag==0
    [ps,D]=size(x);
    initial_flag=1;
    fun_num=10;
%     load hybrid_func1_data % saved the predefined optima
%     if length(o(1,:))>=D
%         o=o(:,1:D);
%     else
        o=-5+10*rand(fun_num,D);
%     end
    func.f1=str2func('fsphere');
    func.f2=str2func('fsphere');
    func.f3=str2func('fsphere');
    func.f4=str2func('fsphere');
    func.f5=str2func('fsphere');
    func.f6=str2func('fsphere');
    func.f7=str2func('fsphere');
    func.f8=str2func('fsphere');
    func.f9=str2func('fsphere');
    func.f10=str2func('fsphere');
    bias=((1:fun_num)-1).*100;
    sigma=ones(1,fun_num);
    lamda=[5/100; 5/100; 5/100; 5/100; 5/100; 5/100; 5/100; 5/100; 5/100; 5/100];
    lamda=repmat(lamda,1,D);
    for i=1:fun_num
        eval(['M.M' int2str(i) '=diag(ones(1,D));']);
    end
end
fit=hybrid_composition_func(x,fun_num,func,o,sigma,lamda,bias,M);
end

