
function [opts,CostFunction] = Get_Functions_Details1(F)


switch F
    case 'F1'
        CostFunction = @F1;
        opts.RangeMin=-100;
        opts.RangeMax=100;
        opts.dim=30;
        
    case 'F2'
        CostFunction = @F2;
        opts.RangeMin=-10;
        opts.RangeMax=10;
        opts.dim=30;
        
    case 'F3'
        CostFunction = @F3;
        opts.RangeMin=-100;
        opts.RangeMax=100;
        opts.dim=30;
        
    case 'F4'
        CostFunction = @F4;
        opts.RangeMin=-100;
        opts.RangeMax=100;
        opts.dim=30;
        
    case 'F5'
        CostFunction = @F5;
        opts.RangeMin=-30;
        opts.RangeMax=30;
        opts.dim=30;
        
    case 'F6'
        CostFunction = @F6;
        opts.RangeMin=-100;
        opts.RangeMax=100;
        opts.dim=30;
        
    case 'F7'
        CostFunction = @F7;
        opts.RangeMin=-1.28;
        opts.RangeMax=1.28;
        opts.dim=30;
        
    case 'F8'
        CostFunction = @F8;
        opts.RangeMin=-500;
        opts.RangeMax=500;
        opts.dim=30;
        
    case 'F9'
        CostFunction = @F9;
        opts.RangeMin=-5.12;
        opts.RangeMax=5.12;
        opts.dim=30;
        
    case 'F10'
        CostFunction = @F10;
        opts.RangeMin=-32;
        opts.RangeMax=32;
        opts.dim=30;
        
    case 'F11'
        CostFunction = @F11;
        opts.RangeMin=-600;
        opts.RangeMax=600;
        opts.dim=30;
        
    case 'F12'
        CostFunction = @F12;
        opts.RangeMin=-50;
        opts.RangeMax=50;
        opts.dim=30;
        
    case 'F13'
        CostFunction = @F13;
        opts.RangeMin=-50;
        opts.RangeMax=50;
        opts.dim=30;
        
    case 'F14'
        CostFunction = @F14;
        opts.RangeMin=-65.536;
        opts.RangeMax=65.536;
        opts.dim=2;
        
    case 'F15'
        CostFunction = @F15;
        opts.RangeMin=-5;
        opts.RangeMax=5;
        opts.dim=30;
        
    case 'F16'
        CostFunction = @F16;
        opts.RangeMin=-5;
        opts.RangeMax=5;
        opts.dim=30;
        
    case 'F17'
        CostFunction = @F17;
        opts.RangeMin=[-5,0];
        opts.RangeMax=[10,15];
        opts.dim=30;
        
    case 'F18'
        CostFunction = @F18;
        opts.RangeMin=-2;
        opts.RangeMax=2;
        opts.dim=30;
        
    case 'F19'
        CostFunction = @F19;
        opts.RangeMin=0;
        opts.RangeMax=1;
        opts.dim=3;
        
    case 'F20'
        CostFunction = @F20;
        opts.RangeMin=0;
        opts.RangeMax=1;
        opts.dim=6;     
        
    case 'F21'
        CostFunction = @F21;
        opts.RangeMin=0;
        opts.RangeMax=10;
        opts.dim=4;    
        
    case 'F22'
        CostFunction = @F22;
        opts.RangeMin=0;
        opts.RangeMax=10;
        opts.dim=4;    
        
    case 'F23'
        CostFunction = @F23;
        opts.RangeMin=0;
        opts.RangeMax=10;
        opts.dim=30; 

end

end

% F1

function o = F1(x)
o=sum(x.^2);
end

% F2

function o = F2(x)
o=sum(abs(x))+prod(abs(x));
end

% F3

function o = F3(x)
dim=size(x,2);
o=0;
for i=1:dim
    o=o+sum(x(1:i))^2;
end
end

% F4

function o = F4(x)
o=max(abs(x));
end

% F5

function o = F5(x)
dim=size(x,2);
o=sum(100*(x(2:dim)-(x(1:dim-1).^2)).^2+(x(1:dim-1)-1).^2);
end

% F6

function o = F6(x)
o=sum(abs((x+.5)).^2);
end

% F7

function o = F7(x)
dim=size(x,2);
o=sum([1:dim].*(x.^4))+rand;
end

% F8

function o = F8(x)
o=sum(-x.*sin(sqrt(abs(x))));
end

% F9

function o = F9(x)
dim=size(x,2);
o=sum(x.^2-10*cos(2*pi.*x))+10*dim;
end

% F10

function o = F10(x)
dim=size(x,2);
o=-20*exp(-.2*sqrt(sum(x.^2)/dim))-exp(sum(cos(2*pi.*x))/dim)+20+exp(1);
end

% F11

function o = F11(x)
dim=size(x,2);
o=sum(x.^2)/4000-prod(cos(x./sqrt([1:dim])))+1;
end

% F12

function o = F12(x)
dim=size(x,2);
o=(pi/dim)*(10*((sin(pi*(1+(x(1)+1)/4)))^2)+sum((((x(1:dim-1)+1)./4).^2).*...
(1+10.*((sin(pi.*(1+(x(2:dim)+1)./4)))).^2))+((x(dim)+1)/4)^2)+sum(Ufun(x,10,100,4));
end

% F13

function o = F13(x)
dim=size(x,2);
o=.1*((sin(3*pi*x(1)))^2+sum((x(1:dim-1)-1).^2.*(1+(sin(3.*pi.*x(2:dim))).^2))+...
((x(dim)-1)^2)*(1+(sin(2*pi*x(dim)))^2))+sum(Ufun(x,5,100,4));
end

% F14

function o = F14(x)
aS=[-32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32 -32 -16 0 16 32;,...
-32 -32 -32 -32 -32 -16 -16 -16 -16 -16 0 0 0 0 0 16 16 16 16 16 32 32 32 32 32];

for j=1:25
    bS(j)=sum((x'-aS(:,j)).^6);
end
o=(1/500+sum(1./([1:25]+bS))).^(-1);
end

% F15

function o = F15(x)
aK=[.1957 .1947 .1735 .16 .0844 .0627 .0456 .0342 .0323 .0235 .0246];
bK=[.25 .5 1 2 4 6 8 10 12 14 16];bK=1./bK;
o=sum((aK-((x(1).*(bK.^2+x(2).*bK))./(bK.^2+x(3).*bK+x(4)))).^2);
end

% F16

function o = F16(x)
o=4*(x(1)^2)-2.1*(x(1)^4)+(x(1)^6)/3+x(1)*x(2)-4*(x(2)^2)+4*(x(2)^4);
end

% F17

function o = F17(x)
o=(x(2)-(x(1)^2)*5.1/(4*(pi^2))+5/pi*x(1)-6)^2+10*(1-1/(8*pi))*cos(x(1))+10;
end

% F18

function o = F18(x)
o=(1+(x(1)+x(2)+1)^2*(19-14*x(1)+3*(x(1)^2)-14*x(2)+6*x(1)*x(2)+3*x(2)^2))*...
    (30+(2*x(1)-3*x(2))^2*(18-32*x(1)+12*(x(1)^2)+48*x(2)-36*x(1)*x(2)+27*(x(2)^2)));
end

% F19

function o = F19(x)
aH=[3 10 30;.1 10 35;3 10 30;.1 10 35];cH=[1 1.2 3 3.2];
pH=[.3689 .117 .2673;.4699 .4387 .747;.1091 .8732 .5547;.03815 .5743 .8828];
o=0;
for i=1:4
    o=o-cH(i)*exp(-(sum(aH(i,:).*((x-pH(i,:)).^2))));
end
end

% F20

function o = F20(x)
aH=[10 3 17 3.5 1.7 8;.05 10 17 .1 8 14;3 3.5 1.7 10 17 8;17 8 .05 10 .1 14];
cH=[1 1.2 3 3.2];
pH=[.1312 .1696 .5569 .0124 .8283 .5886;.2329 .4135 .8307 .3736 .1004 .9991;...
.2348 .1415 .3522 .2883 .3047 .6650;.4047 .8828 .8732 .5743 .1091 .0381];
o=0;
for i=1:4
    o=o-cH(i)*exp(-(sum(aH(i,:).*((x-pH(i,:)).^2))));
end
end

% F21

function o = F21(x)
aSH=[4 4 4 4;1 1 1 1;8 8 8 8;6 6 6 6;3 7 3 7;2 9 2 9;5 5 3 3;8 1 8 1;6 2 6 2;7 3.6 7 3.6];
cSH=[.1 .2 .2 .4 .4 .6 .3 .7 .5 .5];

o=0;
for i=1:5
    o=o-((x-aSH(i,:))*(x-aSH(i,:))'+cSH(i))^(-1);
end
end

% F22

function o = F22(x)
aSH=[4 4 4 4;1 1 1 1;8 8 8 8;6 6 6 6;3 7 3 7;2 9 2 9;5 5 3 3;8 1 8 1;6 2 6 2;7 3.6 7 3.6];
cSH=[.1 .2 .2 .4 .4 .6 .3 .7 .5 .5];

o=0;
for i=1:7
    o=o-((x-aSH(i,:))*(x-aSH(i,:))'+cSH(i))^(-1);
end
end

% F23

function o = F23(x)
aSH=[4 4 4 4;1 1 1 1;8 8 8 8;6 6 6 6;3 7 3 7;2 9 2 9;5 5 3 3;8 1 8 1;6 2 6 2;7 3.6 7 3.6];
cSH=[.1 .2 .2 .4 .4 .6 .3 .7 .5 .5];

o=0;
for i=1:10
    o=o-((x-aSH(i,:))*(x-aSH(i,:))'+cSH(i))^(-1);
end
end

function o = F24(x)
o=0;
% for i=1:10
dim=size(x,2);
o=(-sum(sin(x)*(sin(x(1:dim).^2/pi)).^20));
end

function o=Ufun(x,a,k,m)
o=k.*((x-a).^m).*(x>a)+k.*((-x-a).^m).*(x<(-a));
end