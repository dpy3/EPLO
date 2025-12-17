function fit=func5_shifted_rotated_ackley(x)
% global initial_flag
% persistent o
% [ps,D]=size(x);
% if initial_flag==0
%     o=600*rand(1,D);
%     initial_flag=1;
% end
% c=1;
% M=rot_matrix(D,c);
% z=x-repmat(o,ps,1);
% z=z*M;
% fit=-20*exp(-0.2*sqrt(sum(z.^2)/D))-exp(sum(cos(2*pi*z))/D)+20+exp(1);
global initial_flag
persistent o M
[ps,D]=size(x);
if initial_flag==0
    load ('ackley_func_data','o');
    if length(o)>=D
        o=o(1:D);
    else
        o=-32+64*rand(1,D);
    end
    o(2.*(1:floor(D/2))-1)=-32;
    c=100;
    if D==2,load ('ackley_M_D2','M'),
    elseif D==10,load ('ackley_M_D10','M'),
    elseif D==30,load ('ackley_M_D30','M'),
    elseif D==50,load ('ackley_M_D50','M'),
    else
        M=rot_matrix(D,c);
    end
    initial_flag=1;
end
x=x-repmat(o,ps,1);
x=x*M;
fit=sum(x.^2,2);
fit=-20.*exp(-0.2.*sqrt(fit./D))-exp(sum(cos(2.*pi.*x),2)./D)+exp(1);

