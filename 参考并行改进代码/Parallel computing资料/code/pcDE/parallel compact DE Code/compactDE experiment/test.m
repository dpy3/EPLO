
len=1;
me=zeros(1,len);
y=2*0.99-1;
for i=1:len
    me(i)=myerfinv(y(i));
end
x=sqrt(2)*me.*1+0;
x

a=myerf(0.5);
b=myerfinv(a);
b