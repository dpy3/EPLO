function fit = func17_generalized_penalized_2(x)
   n=length(x);   
   fit=0.1*(10*(sin (y(x(1))*pi))^2 + sum( (y(x(1:n-1))-1).^2 .* (1+10*(sin( y(x(2:n))*pi )).^2))+ (y(x(n))-1)^2)+sum(u(x,5,100,4));
%    fit=0.1*(sin(3*pi*x(1))^2+sum((x(1:n-1)-1).^2.*(1+sin(3*pi*x(2:n)).^2)));
end

