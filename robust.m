clc;
clear;
close all;
%%  noise
data=[22.7675	22.2195
23.20042426	23.09968356
27.30131844	25.68017278
47.85752413	30.60549673
0 0
40.015	38.873
42.53933914	39.46917367
51.40642404	46.73488571
88.49295911	60.32979775];
b=bar(data,'BarWidth',0.5)
b(1).FaceColor =[118 160 173]./255;
b(2).FaceColor = [218 190 132]./255;
set(b,'edgecolor', [1,1,1]);
ylim([0,100]);
xline(5,'--r','linewidth',1.5)
ylabel('MAE','FontSize',15);
set(gca,'ycolor','k','Xgrid','on');
set(gca,'Fontname','Times New Roman','XTickLabel',...,
    {'Raw data','-15db','-30db','-45db',' ','Raw data','-15db','-30db','-45db'},'FontSize',15);
legend('\fontname{Times new roman}FT-based ','\fontname{Times new roman}IPT-based ','FontSize',15,'Location','NorthWest');
xlabel('(a)','FontSize',15);
txt1 = 'PeMS';
txt2 = 'Highway England';
text(2.5,75,txt1,'FontSize',15,'Fontname','Times New Roman')
text(6.5,75,txt2,'FontSize',15,'Fontname','Times New Roman')

%%  miss
data=[22.7675	22.2195
26.04720273	23.57300634
28.76927727	24.87791764
30.82255743	26.15553507
0 0
40.015	38.873
40.29385394	40.03813047
45.52069935	41.07207693
51.86691459	43.52005972];
b=bar(data,'BarWidth',0.5)
b(1).FaceColor =[118 160 173]./255;
b(2).FaceColor = [218 190 132]./255;
set(b,'edgecolor', [1,1,1]);
ylim([0,70]);
xline(5,'--r','linewidth',1.5)
ylabel('MAE','FontSize',15);
set(gca,'ycolor','k','Xgrid','on');
set(gca,'Fontname','Times New Roman','XTickLabel',...,
    {'Raw data','3%','6%','9%',' ','Raw data','3%','6%','9%'},'FontSize',15);
legend('\fontname{Times new roman}FT-based ','\fontname{Times new roman}IPT-based ','FontSize',15,'Location','NorthWest');
xlabel('(b)','FontSize',15);
txt1 = 'PeMS';
txt2 = 'Highway England';
text(2.5,50,txt1,'FontSize',15,'Fontname','Times New Roman')
text(6.5,50,txt2,'FontSize',15,'Fontname','Times New Roman')