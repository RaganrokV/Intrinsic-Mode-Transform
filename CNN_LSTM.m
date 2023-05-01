clc;
clear;
close all;
%% 加载数据
% load('ROAD_NET')
% traffic_flow=ROAD_NET';
%%
load('MIDAS');
traffic_flow=MIDAS(17381:end,:);%使用6个月数据
trainset=672*21;%训练样本尺寸
Sampling_interval=15;%采样间隔
weeks_point=672;%一周时间戳
[data,gy]=mapminmax(traffic_flow',0,1);%
data=data';
%% 归一化
% [data,gy]=mapminmax(ROAD_NET',0,1);%
% data=data';
%% 模型
for k=1:1
tic
% 多步
for i=1:5
    %% 设定预测步长
    if i==1
        FCL=1;
    else
        FCL=3*(i-1);%12步60分钟
    end
    %% 设定输入步长
    SIL=12;
 %% 样本集
 P_input=cell(length(data)-SIL-FCL+1,1);
for j=1:length(data)-SIL-FCL+1
    P_input{j,1}=data(j:j+SIL-1,:);
end
P_output=data(SIL+FCL:end,k);
trainset=12096;%训练样本尺寸
P_input_train=P_input(1:trainset);P_output_train=P_output(1:trainset);
P_input_test=P_input(trainset+1:end);P_output_test=P_output(trainset+1:end);
%%  CNN+LSTM
% 模型结构设置
lgraph = layerGraph();
tempLayers = [
    sequenceInputLayer([12 13 1],"Name","input")
    sequenceFoldingLayer("Name","seqfold")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution2dLayer([6 6],32,"Name","conv","Padding","same")
    averagePooling2dLayer([3 3],"Name","avgpool2d","Padding","same")
    batchNormalizationLayer("Name","batchnorm")
    eluLayer(1,"Name","elu")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    sequenceUnfoldingLayer("Name","sequnfold")
    flattenLayer("Name","flatten")
    lstmLayer(64,'OutputMode','last',"Name","bilstm")
    dropoutLayer(0.3,"Name","drop")
    fullyConnectedLayer(1,"Name","fc")
    regressionLayer("Name","regressionoutput")];
lgraph = addLayers(lgraph,tempLayers);
% 清理辅助变量
clear tempLayers;
lgraph = connectLayers(lgraph,"seqfold/out","conv");
lgraph = connectLayers(lgraph,"seqfold/miniBatchSize","sequnfold/miniBatchSize");
lgraph = connectLayers(lgraph,"elu","sequnfold/in");
% plot(lgraph);
% figure
% plot(lgraph)
% analyzeNetwork(lgraph)
%% 模型参数设置
options = trainingOptions('adam', ...
    'MaxEpochs',100, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',20, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0);
%%  训练
net = trainNetwork(P_input_train,P_output_train,lgraph,options);
toc
t1=toc

tic
%% 仿真
[net1,CNNLSTM_simu_P]=predictAndUpdateState(net,P_input_test,'ExecutionEnvironment','cpu');
%训练期间的预测值
[net2,simu_train_P]=predictAndUpdateState(net,P_input_train,'ExecutionEnvironment','cpu');
%% 反归一
simu_P = mapminmax("reverse",CNNLSTM_simu_P',gy);
simu_P=simu_P(k,:);
real_P =  mapminmax("reverse",P_output_test',gy);
real_P =real_P (k,:);
CNNLSTM_error{k,i}=simu_P'-real_P';
%% 误差
Esemble_result(i,:)=metrics(CNNLSTM_error{k,i}, real_P');
end
ALL_Esemble_result{1,k}=Esemble_result;
toc
t2=toc
end
%% 均值
TEM=zeros(5,6);
for k=1:12
    TEM=TEM+ALL_Esemble_result{1,k};
end
average_result=TEM./12;
%% 保存误差
for i=1:5
    tem=CNNLSTM_error{1,i}*.0;
for k=1:12
        tem=tem+CNNLSTM_error{k,i};
end
    error_CNNLSTM{i,1}=tem./12;
end
save error_CNNLSTM.mat  error_CNNLSTM 