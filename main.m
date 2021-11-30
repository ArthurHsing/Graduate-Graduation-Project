clear all;close all;clc;
setSystemConfig();


[changeRateResult] = arriveRateChange(); %任务到达率的改变
arriveRateChange_draw(changeRateResult); %画图

% global systemConfig;
% systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*30;
% systemConfig.taskComputationIntensityPerBit = 1;
% myOffload();

% global systemConfig;
% systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*1;
% averageCompletionTime = mmssOffload();
% disp(averageCompletionTime);

% global systemConfig;
% systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*1;
% allInEdgeOffload();

% global systemConfig;
% systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*1;
% allInCloudOffload();

% global systemConfig;
% systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*1;
% randomOffload();