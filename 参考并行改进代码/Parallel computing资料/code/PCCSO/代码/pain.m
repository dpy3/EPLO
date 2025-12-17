PSO = xlsread('PCCSO','PSO','1:28');
CSO = xlsread('PCCSO','CSO','1:28');
   PCSO = xlsread('PCCSO','PCSO','1:28');
 CCSO = xlsread('PCCSO','CCSO','1:28');
  PCCSO1 = xlsread('PCCSO','PCCSO1','1:28');
PCCSO2= xlsread('PCCSO','PCCSO2','1:28');
PCCSO3= xlsread('PCCSO','PCCSO3','1:28');
%  DVHop = xlsread('GBMO','1','7:14');
%    LDVHop = xlsread('GBMO','2','7:14');
%  PLDVHop= xlsread('GBMO','3','7:14');
%   GLDVHop = xlsread('GBMO','4','7:14');
% CLDVHop= xlsread('GBMO','5','7:14');

%  DvHop= xlsread('CSO','Dv-Hop','8:10');
%  PSO = xlsread('CSO','Dv-Hop-PSO','8:10');
%  CSO = xlsread('CSO','Dv-Hop-CSO','8:10');
% CCSO = xlsread('CSO','Dv-Hop-CCSO','8:10');
%  
 for i =16
    figure (i)
    plot(PSO(i,(1:20)),'k-','LineWidth',1.5,'Marker','s','MarkerFaceColor','k');
       hold on;
   plot(CSO(i,(1:20)),'c-','LineWidth',1.5,'Marker','+','MarkerFaceColor','c');
       hold on;
         plot(PCSO(i,(1:20)),'r-','LineWidth',1.5,'Marker','o','MarkerFaceColor','red');
    hold on;
     plot(CCSO(i,(1:20)),'m-','LineWidth',1.5,'Marker','*','MarkerFaceColor','m');
    hold on;
    plot(PCCSO1(i,(1:20)),'g-','LineWidth',1.5,'Marker','v','MarkerFaceColor','g');
    hold on;
    plot(PCCSO2(i,(1:20)),'b-','LineWidth',1.5,'Marker','x','MarkerFaceColor','b');
     hold on;  
      plot(PCCSO3(i,(1:20)),'y-','LineWidth',1.5,'Marker','d','MarkerFaceColor','y');
     hold on;
%  plot(DVHop(i,(1:6)),'r-o','LineWidth',1.5,'Marker','+','MarkerFaceColor','red');
%     hold on;
%    plot(LDVHop(i,(1:6)),'g-o','LineWidth',1.5,'Marker','o','MarkerFaceColor','g');
%    hold on;
%    plot(PLDVHop(i,(1:6)),'b-o','LineWidth',1.5,'Marker','*','MarkerFaceColor','b');
%    hold on;
%     plot(GLDVHop(i,(1:6)),'m-o','LineWidth',1.5,'Marker','v','MarkerFaceColor','m');
%      hold on;
%      plot(CLDVHop(i,(1:6)),'c-o','LineWidth',1.5,'Marker','x','MarkerFaceColor','c');
%  
%     title('Convergence Curve');     
%   xlim([0, 8000]);%只设定x轴的绘制范围
% % set(gca,'XTick',[1:2000:40000]) ;%改变x轴坐标间隔显示 这里间隔为2
% % set(gca,'xtick',1:4000:40000) 
%  set(gca,'xticklabel',{'0','600','1200','1800','2400','3000','3600','4200','4800','5400','6000'});
 set(gca,'xticklabel',{'0','8000','16000','24000','32000','40000','48000','56000','64000','72000','80000'});
 xlabel('Number of Solution Test');
 ylabel('Fitness Value');
   legend('PSO','CSO','PCSO','CCSO','PCCSO-BR','PCCSO-AR','PCCSO-WR');
%  set(gca,'xticklabel',{'15.0','17.5','20.0','22.5','25.0','27.5','30.0','32.5','35.0','37.5','40.0'});
%  xlabel('Number of Beacon Nodes');
%  ylabel('Localization Error%');
%        legend('DV-Hop','LDV-Hop','PSO-LDV-Hop','GBMO-LDV-Hop','CGBMO-LDV-Hop');

end