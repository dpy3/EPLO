function rndfuncout=truncrndn(mu,sigma)
len=length(mu);
nmin=-1*ones(1,len);
nmax=1*ones(1,len);
s1=sigma*sqrt(2);
pdfmax=(nmax-mu)./s1;
pdfmin=(nmin-mu)./s1;
umin=zeros(1,len);
umax=zeros(1,len);
for i=1:len
    umin(i)=myerf(pdfmin(i));
    umax(i)=myerf(pdfmax(i));
end
u=umin+(umax-umin).*rand(1,len);
% u=-1+2*rand(1,len);
me=zeros(1,len);
for i=1:len
    me(i)=myerfinv(u(i));
end
rndfuncout=s1.*me+mu;
% R=normrnd(mu,sigma);
% for i=1:len
%    if abs(rndfuncout(i))>1
%        rndfuncout(i)=R(i);
%    end
% end
end


% rndfuncout=zeros(1,length(mu));
% for i=1:length(mu)
% rndfuncout(i)=norminv(rand,mu(i),sigma(i));
% end
% maxx=max(rndfuncout);
% minx=min(rndfuncout);
% for i=1:length(mu)
% rndfuncout(i)=(rndfuncout(i)-minx)*1.98/(maxx-minx)-0.99;
% end
% end
