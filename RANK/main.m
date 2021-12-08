close all
clear all

printirf=false;

pars % set parameters for all models

%% solve models

main_NK % 

main_YN

main_NKcap

main_YNcap

%% Figure IRF-RANK



RANKcol =  [0.2 0.2 1.0];
WCNKcol =  [1 0 0.83];
WCNKcol2 =  [1 0 0];


figure(1)
clf

%output
subplot(4,2,1)

plot(IRF_NK(23,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot(IRF_YN(23,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Output gap')

legend('RANK','RANK-YN','Location','southeast')

ylabel('PP')

%inflation
subplot(4,2,2)

plot(IRF_NK(11,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot(IRF_YN(11,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')


hline=refline(0,0);
hline.Color='black';
title('Inflation')

%consumption 
subplot(4,2,3)

plot(IRF_NK(19,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot(IRF_YN(19,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Consumption')

ylabel('PP')


%investment
subplot(4,2,4)

plot(IRF_NK(17,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot(IRF_YN(17,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Investment')


%Hours
subplot(4,2,5)

plot(IRF_NK(14,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot(IRF_YN(14,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Hours')

ylabel('PP')

%Real wages
subplot(4,2,6)

plot(IRF_NK(6,2:end)*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot(IRF_YN(6,2:end)*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Real wages')


%Labour share
subplot(4,2,7)

plot(IRF_NK(21,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot(IRF_YN(21,1:end-1)*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Labour share')
ylabel('PP')

%Productivity
subplot(4,2,8)

plot((IRF_NK(23,1:end-1)-IRF_NK(14,2:end))*100,'Color',RANKcol,'LineWidth',1.8)
hold on

plot((IRF_YN(23,1:end-1)-IRF_YN(14,2:end))*100,'Color',RANKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Labour productivity')


%% Figure IRF-WCNK

figure(2)
clf

%output
subplot(3,2,1)

plot(IRF_NKcap(22,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8)
hold on

plot(IRF_YNcap(22,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Output gap')

legend('WCNK','WCNK-YN','Location','southeast')

ylabel('PP')

%inflation
subplot(3,2,2)

plot(IRF_NKcap(10,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8)
hold on

plot(IRF_YNcap(10,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8,'LineStyle','--')



hline=refline(0,0);
hline.Color='black';
title('Inflation')

%Consumption: Worker & Entrepeur
subplot(3,2,3)

c11=plot(IRF_NKcap(25,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8);
hold on

c12=plot(IRF_NKcap(24,1:end-1)*100,'Color',WCNKcol2,'LineWidth',1.8);
hold on

c13=plot(IRF_YNcap(30,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8,'LineStyle','--');
hold on

c14=plot(IRF_YNcap(29,1:end-1)*100,'Color',WCNKcol2,'LineWidth',1.8,'LineStyle','--');

hline=refline(0,0);
hline.Color='black';

legend([c11 c12 c13 c14],{'Worker','Entrepeneur'},'Location','southeast')

title('Consumption: Worker & Entrepreneur')

ylabel('PP')

%Investment
subplot(3,2,4)

plot(IRF_NKcap(16,2:end)*100,'Color',WCNKcol,'LineWidth',1.8)
hold on

plot(IRF_YNcap(16,2:end)*100,'Color',WCNKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Investment')

%Labour share
subplot(3,2,5)

plot(IRF_NKcap(20,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8)
hold on

plot(IRF_YNcap(20,1:end-1)*100,'Color',WCNKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Labour share')
ylabel('PP')

%Productivity
subplot(3,2,6)

plot((IRF_NKcap(22,1:end-1)-IRF_NKcap(13,2:end))*100,'Color',WCNKcol,'LineWidth',1.8)
hold on

plot((IRF_YNcap(22,1:end-1)-IRF_YNcap(13,2:end))*100,'Color',WCNKcol,'LineWidth',1.8,'LineStyle','--')

hline=refline(0,0);
hline.Color='black';
title('Labour productivity')

%% save figures

figure(1)
h = gcf;
set(h,'Units','centimeters');
h.Position(1) =0;
h.Position(2) =0;
h.Position(3) =20;
h.Position(4) =20;
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(h,'../charts/IRF_RANK','-dpdf','-r0')

figure(2)
h = gcf;
set(h,'Units','centimeters');
h.Position(1) =0;
h.Position(2) =0;
h.Position(3) =20;
h.Position(4) =20;
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(h,'../charts/IRF_WCNK','-dpdf','-r0')




