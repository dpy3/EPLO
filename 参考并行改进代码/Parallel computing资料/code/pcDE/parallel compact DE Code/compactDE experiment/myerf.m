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