function fit=func3_rosenbrock(x)
D=length(x);
% fit=0;
% for i=1:D-1
%     fit=fit+100*(x(i)^2-x(i+1))^2+(x(i)-1)^2;
% end
fit=sum(100.*(x(1:D-1).^2-x(2:D)).^2+(x(1:D-1)-1).^2);


% global initial_flag
% persistent o
% [ps,D]=size(x);
% if initial_flag==0
%     load rosenbrock_func_data
%     if length(o)>=D
%         o=o(1:D);
%     else
%         o=-90+180*rand(1,D);
%     end
%     initial_flag=1;
% end
% x=x-repmat(o,ps,1)+1;

