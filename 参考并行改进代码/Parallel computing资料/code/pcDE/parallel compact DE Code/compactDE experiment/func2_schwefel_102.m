function fit=func2_schwefel_102(x)
global initial_flag
persistent o
% [ps,D]=size(x);
D=length(x);
if initial_flag==0
    load ('schwefel_102_data','o');
    if length(o)>=D
        o=o(1:D);
    else
        o=-100+200*rand(1,D);
    end
%      o=zeros(1,D);
     initial_flag=1;
end
% x=x-repmat(o,ps,1);
x=x-o;
fit=0;
for i=1:D
    fit=fit+sum(x(:,1:i),2).^2;
end
end


