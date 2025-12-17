function x=generateIndividualR(P,sigma2)
nv=length(P);
x=2*ones(1,nv);

 for i=1:nv
   trial=0;
   while ((abs(x(i))>1) && trial < 10)
       trial=trial+1;
       x(i)=randn*sqrt(sigma2(i))+P(i);
   end
   if (abs(x(i))>1)
       x(i)=truncrndn(rand,P(i),sqrt(sigma2(i)));
   end
 end
 
 function rndfuncout=truncrndn(r,m,sigma)
%y=truncatedrandn(m,sigma,n,nmin,nmax)
%truncatedrandn.m genera n numeri casuali con distribuzione normale a media
%m e deviazione std sigma (varianza sigma^2).
%Nmin ed Nmax sono il valore minimo e massimo del numeri casuali generati.
%
%Questa funzione genera numeri casuali con distribuzione gaussiana
%utilizzando il Teorma dell'Inversione ed una approssimazione razionale
%di Chebyshec della funzione erf(x).
%E.Mininno, 2005

%rndfuncout=1;
nmin=-1; nmax=1;

s1=sqrt(2)*sigma;
pdfmax=(nmax-m)/s1;
pdfmin=(nmin-m)/s1;

umin=myerf(pdfmin);
umax=myerf(pdfmax);

u0=r;
u=umin+(umax-umin).*u0;

me=myerfinv(u);
rndfuncout=s1.*me+m;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = myerf(xin)
%ERFCORE Core algorithm for error functions.
%   erf(x) = erfcore(x,0)
%   erfc(x) = erfcore(x,1)
%   erfcx(x) = exp(x^2)*erfc(x) = erfcore(x,2)

%   This is a translation of a FORTRAN program by W. J. Cody,
%   Argonne National Laboratory, NETLIB/SPECFUN, March 19, 1990.
%   The main computation evaluates near-minimax approximations
%   from "Rational Chebyshev approximations for the error function"
%   by W. J. Cody, Math. Comp., 1969, PP. 631-638.


%
%   evaluate  erf  for  |x| <= 0.46875
%
    result=0;
    xbreak = 0.46875;
    if (abs(xin) <= xbreak)
        acoef = [3.16112374387056560e00; 1.13864154151050156e02;
             3.77485237685302021e02; 3.20937758913846947e03;
             1.85777706184603153e-1];
        bcoef = [2.36012909523441209e01; 2.44024637934444173e02;
             1.28261652607737228e03; 2.84423683343917062e03];

            y = abs(xin);
            z = y .* y;
            xnum = acoef(5)*z;
            xden = z;
            for index = 1:3
               xnum = (xnum + acoef(index)) .* z;
               xden = (xden + bcoef(index)) .* z;
            end
            result = xin .* (xnum + acoef(4)) ./ (xden + bcoef(4));
    end
%
%   evaluate  erfc  for 0.46875 <= |x| <= 4.0
%

    if ((abs(xin) > xbreak) &&  (abs(xin) <= 4.))
        ccoef = [5.64188496988670089e-1; 8.88314979438837594e00;
             6.61191906371416295e01; 2.98635138197400131e02;
             8.81952221241769090e02; 1.71204761263407058e03;
             2.05107837782607147e03; 1.23033935479799725e03;
             2.15311535474403846e-8];
        dcoef = [1.57449261107098347e01; 1.17693950891312499e02;
             5.37181101862009858e02; 1.62138957456669019e03;
             3.29079923573345963e03; 4.36261909014324716e03;
             3.43936767414372164e03; 1.23033935480374942e03];

            y = abs(xin);
            xnum = ccoef(9)*y;
            xden = y;
            for index = 1:7
               xnum = (xnum + ccoef(index)) .* y;
               xden = (xden + dcoef(index)) .* y;
            end
            result = (xnum + ccoef(8)) ./ (xden + dcoef(8));
            z = fix(y*16)/16;
            del = (y-z).*(y+z);
            result = exp(-z.*z) .* exp(-del) .* result;
            
    end
%
%   evaluate  erfc  for |x| > 4.0
%

    if (abs(xin) > 4.0)
        p = [3.05326634961232344e-1; 3.60344899949804439e-1;
             1.25781726111229246e-1; 1.60837851487422766e-2;
             6.58749161529837803e-4; 1.63153871373020978e-2];
        q = [2.56852019228982242e00; 1.87295284992346047e00;
             5.27905102951428412e-1; 6.05183413124413191e-2;
             2.33520497626869185e-3];

            y = abs(xin);
            z = 1 ./ (y .* y);
            xnum = p(6).*z;
            xden = z;
            for index = 1:4
               xnum = (xnum + p(index)) .* z;
               xden = (xden + q(index)) .* z;
            end
            result = z .* (xnum + p(5)) ./ (xden + q(5));
            result = (1/sqrt(pi) -  result) ./ y;
            z = fix(y*16)/16;
            del = (y-z).*(y+z);
            result = exp(-z.*z) .* exp(-del) .* result;
    end
%
%   fix up for negative argument, erf, etc.
%
    
if (xin > xbreak)
    result = (0.5 - result) + 0.5;
end

if (xin < -xbreak)
    result = (-0.5 + result) - 0.5;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

y0 = .7;

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

% The relative error of the approximation has absolute value less
% than 8.9e-7.  One iteration of Halley's rational method (third
% order) gives full machine precision.

% Newton's method: new x = x - f/f'
% Halley's method: new x = x - 1/(f'/f - (f"/f')/2)
% This function: f = erf(x) - y, f' = 2/sqrt(pi)*exp(-x^2), f" = -2*x*f'

% Newton's correction
%u = (erf(xo) - y) ./ (2/sqrt(pi) * exp(-x.^2));

% Halley's step
%xo = xo - u./(1+xo.*u);

% Exceptional cases

%xo(yo == -1) = -Inf;
%xo(yo == 1) = Inf;
%xo(abs(yo) > 1) = NaN;
%xo(isnan(yo)) = NaN;