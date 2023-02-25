function result=metrics(error, real_P)
MAE=mae(error);
RMSE = sqrt(mean(error.^2));
MAPE=sum(abs(error./real_P))./length(real_P);
R2=1-(sum((error).^2)/sum((real_P - mean(real_P)).^2));
SK= skewness(error);%偏度
KU=kurtosis(error);%峰度
result=[MAE RMSE MAPE R2 SK KU];
end