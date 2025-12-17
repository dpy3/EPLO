function fit=func7_shifted_rotated_griewank(x)
% global initial_flag
% persistent o
% [ps,D]=size(x);
% if initial_flag==0
%     o=-5+10*rand(1,D);
%     initial_flag=1;
% end
% c=3;
% M=rot_matrix(D,c);
% z=x-repmat(o,ps,1);
% z=z*M;
% fit=sum(sum(z.^2./4000));
global initial_flag
persistent o M
[ps,D]=size(x);
if initial_flag==0
    load griewank_func_data
    if length(o)>=D
        o=o(1:D);
    else
        o=-600+0*rand(1,D);
    end
    c=3;
    if D==2,load griewank_M_D2,,
    elseif D==10,load griewank_M_D10,
    elseif D==30,load griewank_M_D30,
    elseif D==50,load griewank_M_D50,
    else
        M=rot_matrix(D,c);
        M=M.*(1+0.3.*normrnd(0,1,D,D));
    end
    o=o(1:D);
    initial_flag=1;
end
x=x-repmat(o,ps,1);
x=x*M;
fit=1;
for i=1:D
    fit=fit.*cos(x(:,i)./sqrt(i));
end
fit=sum(x.^2,2)./4000-fit+1;
