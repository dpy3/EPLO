function [x,y,f] = CEC2022_plot(func_name,dim)

[lb,ub,dim,fobj]=Get_CEC2022_details(func_name,dim);

x=-100:2:100; y=x; %[-100,100]

L=length(x);
f=[];

for i=1:L
    for j=1:L
        if dim == 2
            f(i,j)=fobj([x(i),y(j)]);
        else
            f(i,j)=fobj([x(i),y(j),zeros(1,dim-2)]);
        end
    end
end

end


