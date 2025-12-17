function f=func9_rastrigin_rotated(x)
global initial_flag
persistent o M
[ps,D]=size(x);
if initial_flag==0
%     load rastrigin_func_data
    if length(o)>=D
        o=o(1:D);
    else
        o=-5+10*rand(1,D);
    end
    c=2;
%     if D==2,load rastrigin_M_D2,
%     elseif D==10,load rastrigin_M_D10,
%     elseif D==30,load rastrigin_M_D30,
%     elseif D==50,load rastrigin_M_D50,
%     else
        M=rot_matrix(D,c);
%     end
    initial_flag=1;
end
x=x-repmat(o,ps,1);
x=x*M;
f=sum(x.^2-10.*cos(2.*pi.*x)+10,2);
