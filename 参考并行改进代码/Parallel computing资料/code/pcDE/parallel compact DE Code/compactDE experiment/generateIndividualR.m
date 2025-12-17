function x=generateIndividualR(mu,sigma)
len=length(mu);
% x=2*ones(1,len);
% for i=1:len
%     trial=0;
%     while ((abs(x(i))>1) && trial < 10)
%         trial=trial+1;
%         x(i)=randn*sigma(i)+mu(i);
%     end
%     if (abs(x(i))>1)
%         x(i)=truncrndn(mu(i),sigma(i));
%     end
% end

me=zeros(1,len);
y=2*(rand(1,len)*0.998+0.001)-1;
for i=1:len
    me(i)=myerfinv(y(i));
end
x=sqrt(2)*me.*sigma+mu;
% for i=1:len
%     while abs(x(i))>1
%     x(i)=-1+2*rand;
%     end
% end
end
% x=zeros(1,length(mu));
% for i=1:length(mu)
% pd = makedist('Normal',mu(i),sigma(i));
% % pdt= truncate(pd,-1,1);
% x(i)=icdf(pd,rand,mu(i),sigma(i));
% end
% % x=truncrndn(mu,sigma);
% end
