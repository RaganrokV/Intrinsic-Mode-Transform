clc;
clear; 
close all;
%% 加载数据
% load('ROAD_NET');
% traffic_flow=ROAD_NET;
% trainset=12096;%训练样本尺寸
% Sampling_interval=5;%采样间隔
% weeks_point=2016;%一周时间戳
%% 数据集2
MIDAS=csvread('MIDAS.csv',1,0);
load('MIDAS');
traffic_flow=MIDAS(17381:end,:);%使用6个月数据
trainset=672*21;%训练样本尺寸
Sampling_interval=15;%采样间隔
weeks_point=672;%一周时间戳

%%
for j=1:5
tic
time_step=12;
    %% 设定预测步长
    if j==1
        out_step=1;
    else
        out_step=3*(j-1);%12步60分钟
    end
 %%
for i=1:1
    
    
    [DT,gy]=mapminmax(traffic_flow(:,i)',0,1);
    [P_input,P_output,P_input_train,P_output_train,P_input_test,P_output_test]=divide(DT,trainset,time_step,out_step);
    %%  elm构建
    [simu_P,simu_train_P ]= ELM(P_input_train,P_output_train,P_input_test ,P_output_test,0, 512, 'sig');
%     反归一
toc
t1=toc

tic
    %%
    ELM_simu_P = mapminmax('reverse',simu_P,gy);
%     real_P = mapminmax('reverse',P_output_test,gy);
    real_P=traffic_flow(end-length(simu_P)+1:end,i);
    error{j,i}=ELM_simu_P(end,:)'-real_P;
    %% 指标
    result =metrics(error{j,i}, real_P);
    METRIC(j,:)=result;
end
t2=toc
AVE_M=mean(METRIC);
% Step(j,:)=AVE_M;
end