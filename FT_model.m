function [Period,Fit_R2]  = FT_model( typical_week,sample_interval)
%sample_interval单位分钟
%% 傅里叶变换拟合  周期
X=1:length(typical_week);
[xData, yData] = prepareCurveData( X, typical_week );
% Set up fittype and options.
F=@(a,a1,b1,x)a+a1*cos(2*pi*x*sample_interval/(24*60))+b1*sin(2*pi*x*sample_interval/(24*60));
ft = fittype(F, 'independent', 'x', 'dependent', 'y' );
% ft = fittype( 'fourier6' );

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Lower = [];
opts.Upper = [];
opts.Display = 'Off';
opts.MaxIter = 1000;
opts.Robust = 'LAR';
opts.TolFun = 1e-07;
opts.TolX = 1e-07;
% Fit model to data.
fittedmodel = fit( xData, yData, ft, opts );
Period=fittedmodel(X);% 周期分量
pre_dec=typical_week-Period;
% figure(2)
% plot(X,typical_week,'--r',X,Period,'k',X,pre_dec,'--b');
Fit_R2=1-(sum((pre_dec).^2)/sum((typical_week - mean(typical_week)).^2));
end