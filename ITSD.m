clc;
clear;
close all;
%% 加载数据
for j=1:14
% load('ROAD_NET');
% traffic_flow=ROAD_NET(:,j);
% trainset=12096;%训练样本尺寸
%% 数据集2
load('MIDAS');
traffic_flow=MIDAS(17381:end,j);%使用6个月数据
trainset=672*21;%训练样本尺寸
%% 构建周
M=672;
N=floor(length(traffic_flow)/M);
L=M*N;
DATA=traffic_flow(1:trainset)';
weeks=reshape(DATA,M,[]);
typical_week=mean(weeks,2);
%% emd-hht提取周期模式 
T=emd(typical_week);
HHT_IMF= hilbert(T);
INF=mean(instfreq(HHT_IMF,1)); %  均值(效果最好)%1为单位时间（每5分钟）的采样数
%% 噪声调整(附加惩罚系数)
Daily_pattern=1/96;%日模式频率1/（24*60/5）
[noise_error,index]=min(abs(INF-Daily_pattern));  % noise_error为调整系数；index为提取日模式位置索引
alpha=Daily_pattern/INF(index);  %alpha为惩罚项
Improve_INF=alpha*INF;
t=1./Improve_INF;
TRANS_t=t*15/60;   %变化为小时以观察周期
% 排序
rank_INF= [fliplr(Improve_INF(1:index)) Improve_INF(index+1:end)];
%% 周期 
fit_typical_week=zeros(numel(typical_week),numel(Improve_INF));
pre_dec=typical_week;
X=1:length(typical_week);
for i=1:numel(INF)
    [xData, yData] = prepareCurveData( X, pre_dec );
    F=@(a,a1,b1, a2, b2 ,a3, b3,x)a+a1*cos(2*pi*x*rank_INF(i))+b1*sin(2*pi*x*rank_INF(i))+a2*cos(4*pi*x*rank_INF(i))+b2*sin(4*pi*x*rank_INF(i))+a3*cos(6*pi*x*rank_INF(i))+b3*sin(6*pi*x*rank_INF(i));
    ft = fittype(F, 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.MaxIter = 4000;
    opts.Robust = 'LAR';
    opts.TolFun = 1e-09;
    opts.TolX = 1e-09;
    [model, gof] = fit( xData, yData, ft, opts );
    fit_typical_week(:,i)=model(X);% 周期分量
    pre_dec=pre_dec-fit_typical_week(:,i);  
end
Period=typical_week-pre_dec;
% figure(1)
% plot(X,typical_week,'--r',X,Period,'k',X,pre_dec,'--b');
Fit_R2(i,:)=1-(sum((pre_dec).^2)/sum((typical_week - mean(typical_week)).^2));
%% 延拓获取周期分量
modeled_Period=Period(mod(1:length(traffic_flow),M)+1);%
error=traffic_flow(trainset+1:end)-modeled_Period(trainset+1:end);
MAE=mae(error);
RMSE = sqrt(mean((error).^2));
MAPE=sum(abs(error./traffic_flow(trainset+1:end)))./length(traffic_flow(trainset+1:end));
R2=1-(sum((error).^2)/sum((traffic_flow(trainset+1:end) - mean(traffic_flow(trainset+1:end))).^2));
result(j,:)=[MAE RMSE MAPE R2];
end