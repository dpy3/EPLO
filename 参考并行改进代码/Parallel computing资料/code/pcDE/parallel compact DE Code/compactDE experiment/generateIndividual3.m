function xoff=generateIndividual3(mu,sigma,elite,F,Cr)
% len=length(mu);
% xoff=zeros(1,len);
% nmin=-1*ones(len);
% nmax=1*ones(len);
% s1=sigma.*sqrt(2);
% pdfmax=(nmax-mu)./s1;
% pdfmin=(nmin-mu)./s1;
% umin=zeros(1,len);
% umax=zeros(1,len);
% for i=1:len
%     umin(i)=myerf(pdfmin(i));
%     umax(i)=myerf(pdfmax(i));
% end
% u1=umin+(umax-umin).*rand(1,len);
% u2=umin+(umax-umin).*rand(1,len);
% u3=umin+(umax-umin).*rand(1,len);
% me1=zeros(1,len);
% me2=zeros(1,len);
% me3=zeros(1,len);
% for i=1:len
%     me1(i)=myerfinv(u1(i));
%     me2(i)=myerfinv(u2(i));
%     me3(i)=myerfinv(u3(i));
% %     if rand<F
%     xoff(i)=s1(i)*me3(i)+mu(i)+s1(i)*(me1(i)-me2(i))*F;
% %     else
% %         xoff(i)=s1(i)*me3(i)+mu(i)+s1(i)*(me1(i)+me2(i)-2*me3(i))*0.5*(1+F);
% %     end
%     if abs(xoff(i))>1
%         xoff(i)=-1+2*rand;
%     end
%     if rand>Cr
%         xoff(i)=elite(i);
%     end
% end
% end


len=length(mu);
xoff=zeros(1,len);
x1=zeros(1,len);
x2=zeros(1,len);
x3=zeros(1,len);
me1=zeros(1,len);
me2=zeros(1,len);
me3=zeros(1,len);
y1=2*(rand(1,len)*0.998+0.001)-1;
y2=2*(rand(1,len)*0.998+0.001)-1;
y3=2*(rand(1,len)*0.998+0.001)-1;
for i=1:len
    me1(i)=myerfinv(y1(i));
    me2(i)=myerfinv(y2(i));
    me3(i)=myerfinv(y3(i));
    x1(i)=sqrt(2)*me1(i)*sigma(i)+mu(i);
    x2(i)=sqrt(2)*me2(i)*sigma(i)+mu(i);
    x3(i)=sqrt(2)*me3(i)*sigma(i)+mu(i);
    xoff(i)=x1(i)+(x2(i)-x3(i))*F;
    if rand>Cr
        xoff(i)=elite(i);
    end
end
end


