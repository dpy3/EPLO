function [f]=func19_weierstrass_rotated(x)
global initial_flag
persistent o M
[ps,D]=size(x);
if initial_flag==0
    load weierstrass_data
    if length(o)>=D
        o=o(1:D);
    else
        o=-0.5+0.5*rand(1,D);
    end
    c=5;
    if D==2,load weierstrass_M_D2,,
    elseif D==10,load weierstrass_M_D10,
    elseif D==30,load weierstrass_M_D30,
    elseif D==50,load weierstrass_M_D50,
    else
        M=rot_matrix(D,c);
    end
    initial_flag=1;
end
x=x-repmat(o,ps,1);
x=x*M;
x=x+0.5;
a = 0.5;%0<a<1
b = 3;
kmax = 20;
[ps,D]=size(x);

c1(1:kmax+1) = a.^(0:kmax);
c2(1:kmax+1) = 2*pi*b.^(0:kmax);
c=-w(0.5,c1,c2);
f=0;
for i=1:D
    f=f+w(x(:,i)',c1,c2);
end
f=f+repmat(c*D,ps,1);

