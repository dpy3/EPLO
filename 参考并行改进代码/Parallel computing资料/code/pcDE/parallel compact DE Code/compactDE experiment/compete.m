function [winner,loser]=compete(a,b,fun_cnum)
global max_x min_x
if(fitness((a+1)*(max_x-min_x)/2+min_x,fun_cnum)<fitness((b+1)*(max_x-min_x)/2+min_x,fun_cnum))
    winner=a;loser=b;
else
    winner=b;loser=a;
end
end

