function fitness=func_2Dentropy(t)
global P
a=floor(t(1));
b=floor(t(2));
PA=sum(sum(P(1:a,1:b)));
HA=log(PA)+(-sum(sum(P(1:a,1:b).*log(P(1:a,1:b)))))/PA;
HL=-sum(sum(P.*log(P)));
fitness=log(PA*(1-PA))+HA/PA+(HL-HA)/(1-PA);
end

