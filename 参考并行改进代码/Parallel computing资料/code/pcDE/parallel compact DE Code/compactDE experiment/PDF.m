% function out = PDF(mu,sigma,umax,umin)
%  syms x y
%  pdf=exp(-1*(x-mu)^2/(2*sigma^2))/(sigma*(umax-umin));
%  cdf=int(pdf,-1,y);
%  cdf
%  iczdf=finverse(cdf,y);
% end

