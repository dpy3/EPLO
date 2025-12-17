function main
close all;
clear;
global initial_flag
test=25;
% for fun_num=test:test
%     initial_flag=0;
%     if fun_num==1
%         max=100;min=-100;dim=30;f=0.9;cr=0.9;                             
%     elseif fun_num==2
%         max=100;min=-100;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==3
%         max=100;min=-100;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==4
%         max=32;min=-32;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==5
%         max=32;min=-32;dim=30;f=0.1;cr=0.1;  
%     elseif fun_num==6
%         max=2^32-1;min=1-2^32;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==7
%         max=0;min=-600;dim=30;f=0.01;cr=0.01;  
%     elseif fun_num==8
%         max=5;min=-5;dim=30;f=0.1;cr=0.01;  
%     elseif fun_num==9
%         max=5;min=-5;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==10
%         max=500;min=-500;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==11
%         max=500;min=-500;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==12
%         max=5;min=-5;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==13
%         max=5;min=-5;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==14
%         max=10;min=-10;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==15
%         max=100;min=-100;dim=30;f=0.5;cr=0.1; 
%     elseif fun_num==16
%         max=50;min=-50;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==17
%         max=50;min=-50;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==18
%         max=10;min=-10;dim=30;f=0.1;cr=0.1;  
%     elseif fun_num==19
%         max=0.5;min=-0.5;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==20
%         max=pi;min=-pi;dim=30;f=0.1;cr=0.1; 
%     elseif fun_num==21
%         max=5;min=-5;dim=4;f=0.1;cr=0.1; 
%     elseif fun_num==22
%         max=5;min=-5;dim=2;f=0.1;cr=0.1; 
%     elseif fun_num==23
%         max=15;min=-5;dim=2;f=0.1;cr=0.1; 
%     elseif fun_num==24
%         max=1;min=0;dim=4;f=0.1;cr=0.1; 
%     elseif fun_num==25
%         max=1;min=0;dim=6;f=0.1;cr=0.1; 
%     elseif fun_num==26
%         max=10;min=0;dim=4;f=0.1;cr=0.1;  
%     elseif fun_num==27
%         max=10;min=0;dim=4;f=0.1;cr=0.1; 
%     elseif fun_num==28
%         max=10;min=0;dim=4;f=0.1;cr=0.1; 
%     elseif fun_num==29
%         max=255;min=0;dim=2;f=0.1;cr=0.1; 
%     end
for fun_num=2:test
    initial_flag=0;
    if fun_num==1
        max=100;min=-100;dim=30;f=0.1;cr=0.1;                             
    elseif fun_num==2
        max=100;min=-100;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==3
        max=100;min=-100;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==4
        max=32;min=-32;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==5
        max=32;min=-32;dim=30;f=0.1;cr=0.1;  
    elseif fun_num==6
        max=2^32-1;min=1-2^32;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==7
        max=0;min=-600;dim=30;f=0.01;cr=0.01;  
    elseif fun_num==8
        max=5;min=-5;dim=30;f=0.1;cr=0.01;  
    elseif fun_num==9
        max=5;min=-5;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==10
        max=500;min=-500;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==11
        max=10;min=-10;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==12
        max=100;min=-100;dim=30;f=0.5;cr=0.1; 
    elseif fun_num==13
        max=50;min=-50;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==14
        max=50;min=-50;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==15
        max=10;min=-10;dim=30;f=0.1;cr=0.1;  
    elseif fun_num==16
        max=0.5;min=-0.5;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==17
        max=pi;min=-pi;dim=30;f=0.1;cr=0.1; 
    elseif fun_num==18
        max=5;min=-5;dim=4;f=0.1;cr=0.1; 
    elseif fun_num==19
        max=5;min=-5;dim=2;f=0.1;cr=0.1; 
    elseif fun_num==20
        max=15;min=-5;dim=2;f=0.1;cr=0.1; 
    elseif fun_num==21
        max=1;min=0;dim=4;f=0.1;cr=0.1; 
    elseif fun_num==22
        max=1;min=0;dim=6;f=0.1;cr=0.1; 
    elseif fun_num==23
        max=10;min=0;dim=4;f=0.1;cr=0.1;  
    elseif fun_num==24
        max=10;min=0;dim=4;f=0.1;cr=0.1; 
    elseif fun_num==25
        max=10;min=0;dim=4;f=0.1;cr=0.1; 
    end
%     pe_cDE(max,min,dim,fun_num,f,cr);
%     ne_cDE(max,min,dim,fun_num,f,cr);
     avgppe_cDE(max,min,dim,fun_num,f,cr);
     avgpne_cDE(max,min,dim,fun_num,f,cr);
%     DE(max,min,dim,fun_num,f,cr);    
end
end



