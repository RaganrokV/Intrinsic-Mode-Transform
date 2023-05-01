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
load('MIDAS');
traffic_flow=MIDAS(17381:end,:);%使用6个月数据
trainset=672*21;%训练样本尺寸
Sampling_interval=15;%采样间隔
weeks_point=672;%一周时间戳
%% 
for j=1:5
tic
%% 设定预测步长
time_step=12;
    if j==1
        out_step=1;
    else
        out_step=3*(j-1);%12步60分钟
    end
%%
for i=1:1

% N_Data = awgn(traffic_flow(:,i)',-45);

totalNum=length(traffic_flow(:,i)');
MISS_TF=traffic_flow(:,i);
randomIndex=1+floor(rand(1,floor(totalNum*0.09))*totalNum);
MISS_TF(randomIndex,:)=0;
[DT,gy]=mapminmax(MISS_TF',0,1);

[P_input,P_output,P_input_train,P_output_train,P_input_test,P_output_test]=divide(DT,trainset,time_step,out_step);
%% LSTM
    layers = [
        sequenceInputLayer(time_step,"Name","input")%输入层
        bilstmLayer(32,"Name","lstm_1")
        dropoutLayer(0.3,"Name","drop1")
        bilstmLayer(16,"Name","lstm_2")
        dropoutLayer(0.3,"Name","drop2")
        fullyConnectedLayer(out_step,"Name","fc")
        regressionLayer("Name","regressionoutput")];
%% 指定训练选项。    
options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',20, ...
    'LearnRateDropFactor',0.2, ...
    'L2Regularization',0.2,...
    'Verbose',0);
%% 训练LSTM
lstm_net = trainNetwork(P_input_train,P_output_train,layers,options);
toc
t1=toc

tic
% 仿真
[lstm_net,simu_P]=predictAndUpdateState(lstm_net,P_input_test,'ExecutionEnvironment','gpu');
% 反归一
simu_P = mapminmax('reverse',simu_P,gy)';
simu_P=simu_P(:,end);
real_P=traffic_flow(end-length(simu_P)+1:end,i);
LSTM_error=simu_P-real_P;
LSTM_result =metrics(LSTM_error, real_P);
LSTM_METRIC(i,:)=LSTM_result;
%% ITSD——model
% 构建周
% TF = awgn(traffic_flow(:,i),-45);
% TF=traffic_flow(:,i);
TF=MISS_TF;
M=weeks_point;
N=floor(length(TF)/M);
L=M*N;
DATA=TF(1:trainset)';
weeks=reshape(DATA,M,[]);
typical_week=mean(weeks,2);
%
[Period,Fit_R2,TRANS_t]=ITSD_model(typical_week,Sampling_interval);
% 延拓获取周期分量
modeled_Period=Period(mod(1:length(TF),M)+1);%
ITSD_error=TF(end-length(simu_P)+1:end)-modeled_Period(end-length(simu_P)+1:end);
ITSD_result =metrics(ITSD_error, real_P);
ITSD_METRIC(i,:)=ITSD_result;
%% 集成学习
LSTM_w=[0.5; (1./LSTM_error.^2)./(((1./LSTM_error.^2)+(1./ITSD_error.^2)))];%残差赋权
FT_w=1-LSTM_w;
Esemble_simu_P=LSTM_w(1:end-1).*simu_P+FT_w(1:end-1).*modeled_Period(end-length(simu_P)+1:end);
error{j,i}=real_P-Esemble_simu_P;
result =metrics(error{j,i}, real_P);
METRIC(j,:)=result;
toc
t2=toc
end

AVE_M=mean(METRIC);
% Step(j,:)=AVE_M;
end