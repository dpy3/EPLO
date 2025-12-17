function o=Levy(Dim)
beta=1.5;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
u=randn(1,Dim)*sigma;
v=randn(1,Dim);
step=u./abs(v).^(1/beta);
o=step;
end