function f=func8_rastrigin(x)
global initial_flag
persistent o
[ps,D]=size(x);
if initial_flag==0
    load rastrigin_func_data
    if length(o)>=D
        o=o(1:D);
    else
        o=-5+10*rand(1,D);
    end
    initial_flag=1;
end
x=x-repmat(o,ps,1);
f=sum(x.^2-10.*cos(2.*pi.*x)+10,2);