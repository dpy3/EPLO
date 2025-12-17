function fit=func4_shifted_ackley(x)
global initial_flag
persistent o
[ps,D]=size(x);
if initial_flag==0
    o=[-2.6790  -17.5258   31.4063   21.4993   28.3296  -27.2078   24.6952   14.2448   16.9449    9.4988 -2.6790  -17.5258   31.4063   21.4993   28.3296  -27.2078   24.6952   14.2448   16.9449    9.4988 -2.6790  -17.5258   31.4063   21.4993   28.3296  -27.2078   24.6952   14.2448   16.9449    9.4988];
    o=o(1,D);
    initial_flag=1;
end
z=x-repmat(o,ps,1);
fit=-20*exp(-0.2*sqrt(sum(z.^2)/D))-exp(sum(cos(2*pi*z))/D)+20+exp(1);
% cos(2*pi*z)
end

