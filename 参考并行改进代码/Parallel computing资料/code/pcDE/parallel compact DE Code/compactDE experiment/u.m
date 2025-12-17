function uout = u(x,a,b,c)
uout=zeros(1,length(x));
for i=1:length(x)
    if x(i)>a
        uout(i)=b*(x(i)-a)^c;
    elseif x(i)>=-a&&x(i)<=a
        uout(i)=0;
    elseif x(i)<-a
        uout(i)=b*(-x(i)-a)^c;    
    end
end
end

