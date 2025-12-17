function fit=func1_sphere(x)
% D=length(x);
% persistent o
% global initial_flag
% if initial_flag==0
%     o=zeros(1,D);
%     initial_flag=1;
% end
% z=x-o;
% fit=sum(z.^2);
% end
global initial_flag
persistent o
[ps,D]=size(x);
if initial_flag==0
    load ('sphere_func_data','o');
    if length(o)>=D
        o=o(1:D);
    else
        o=-100+200*rand(1,D);
    end
    initial_flag=1;
end
x=x-repmat(o,ps,1);
fit=sum(x.^2,2);