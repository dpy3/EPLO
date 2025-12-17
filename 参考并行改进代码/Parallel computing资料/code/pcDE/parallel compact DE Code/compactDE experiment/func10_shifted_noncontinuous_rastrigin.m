function fit=func10_shifted_noncontinuous_rastrigin(x)
global initial_flag
persistent o
[ps,D]=size(x);
if initial_flag==0
%     if length(o)>=D
%         o=o(1:D);
%     else
%         o=-500+1000*rand(1,D);
%     end
    o=420.96*ones(1,D);
    initial_flag=1;
end
z=x-repmat(o,ps,1);
y=zeros(1,D);
for i=1:D
    if abs(z(i))<1/2
        y(i)=z(i);
    else
        y(i)=round(2*z(i))/2;
    end
end
fit=sum(y.^2-10*cos(y.*2*pi)+10);
