function f=func20_schwefel_213(x)%after Fletcher and Powell
global initial_flag
persistent a b A alpha
[ps,D]=size(x);
if initial_flag==0
    initial_flag=1;
%     load schwefel_213_data
%     if length(alpha)>=D
%         alpha=alpha(1:D);a=a(1:D,1:D);b=b(1:D,1:D);
%     else
        alpha=[-0.5435    1.1841    0.0261    1.9805    1.0750    1.0679   -3.0680   -1.5146    0.4310    2.3728 -0.5435    1.1841    0.0261    1.9805    1.0750    1.0679   -3.0680   -1.5146    0.4310    2.3728 -0.5435    1.1841    0.0261    1.9805    1.0750    1.0679   -3.0680   -1.5146    0.4310    2.3728];
        alpha=alpha(1:D);
        a=round(-100+200.*rand(D,D));
        b=round(-100+200.*rand(D,D));
%     end
    alpha=repmat(alpha,D,1);
    A=sum(a.*sin(alpha)+b.*cos(alpha),2);
end

for i=1:ps
    xx=repmat(x(i,:),D,1);
    B=sum(a.*sin(xx)+b.*cos(xx),2);
    f(i,1)=sum((A-B).^2,1);
end
% f=f-460;

