function xo = myerfinv(yo)
%ERFINV Inverse error function.
%   X = ERFINV(Y) is the inverse error function for each element of Y.
%   The inverse error function satisfies y = erf(x), for -1 <= y <= 1
%   and -inf <= x <= inf.
%


xo = 0;

% Coefficients in rational approximations.

acoef = [ 0.886226899 -1.645349621  0.914624893 -0.140543331];
bcoef = [-2.118377725  1.442710462 -0.329097515  0.012229801];
ccoef = [-1.970840454 -1.624906493  3.429567803  1.641345311];
dcoef = [ 3.543889200  1.637067800];

% Central range

y0 = 0.7;

if (abs(yo) <= y0)
    z = yo.^2;
    xo = yo.* (((acoef(4)*z+acoef(3)).*z+acoef(2)).*z+acoef(1))./((((bcoef(4)*z+bcoef(3)).*z+bcoef(2)).*z+bcoef(1)).*z+1);
end;

% Near end points of range

if (( y0 < yo ) && (yo <  1))
    z = sqrt(-log((1-yo)/2));
    xo = (((ccoef(4)*z+ccoef(3)).*z+ccoef(2)).*z+ccoef(1)) ./ ((dcoef(2)*z+dcoef(1)).*z+1);
end

if ((-y0 > yo ) && (yo > -1))
    z = sqrt(-log((1+yo)/2));
    xo = -(((ccoef(4)*z+ccoef(3)).*z+ccoef(2)).*z+ccoef(1)) ./ ((dcoef(2)*z+dcoef(1)).*z+1);
end

