function f=func18_schwefel_206(x)%after Fletcher and Powell
global initial_flag
persistent A B o
[ps,D]=size(x);
if initial_flag==0
    initial_flag=1;
    load schwefel_206_data
    if length(o)>=D
        A=A(1:D,1:D);o=o(1:D);
    else
        o=-100+200*rand(1,D);
        A=round(-100+2*100.*rand(D,D));
        while det(A)==0
            A=round(-100+2*100.*rand(D,D));
        end
    end
    o(1:ceil(D/4))=-100;o(max(floor(0.75*D),1):D)=100;
    B=A*o';
end
for i=1:ps
    f(i,1)=max(abs(A*(x(i,:)')-B));
end
