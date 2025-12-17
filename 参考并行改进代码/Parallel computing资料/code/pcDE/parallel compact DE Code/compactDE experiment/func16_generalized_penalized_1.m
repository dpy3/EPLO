function fit=func16_generalized_penalized_1(x)
   n=length(x);
   fit=(pi/n)*(10*(sin (y(x(1))*pi))^2 + sum( (y(x(1:n-1))-1).^2 .* (1+10*(sin( y(x(2:n))*pi )).^2))+ (y(x(n))-1)^2)+sum(u(x,10,100,4));
end

