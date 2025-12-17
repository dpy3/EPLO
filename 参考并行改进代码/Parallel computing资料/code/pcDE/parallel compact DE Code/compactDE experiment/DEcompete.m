function winner=DEcompete(a,b,fun_cnum)
if(fitness(a,fun_cnum)>=fitness(b,fun_cnum))
    winner=a;
else
    winner=b;
end
end
