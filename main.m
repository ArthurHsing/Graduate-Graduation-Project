clear all;close all;clc;
setSystemConfig();

% global systemConfig;
% systemConfig.wireless.wireless_gains = ones(1, systemConfig.deviceNum); %各个设备与边缘节点的无线信道的信道增益

% [changeRateResult] = arriveRateChange(); %任务到达率的改变
% arriveRateChange_draw(changeRateResult); %画图

% [changeTaskSizeResult] = taskSizeChange(); %任务到达率的改变
% taskSizeChange_draw(changeTaskSizeResult); %画图

[wirelessChannelChangeResult] = wirelessChannelChange(); %任务到达率的改变
wirelessChannelChange_draw(wirelessChannelChangeResult); %画图

% systemConfig.taskSize = (1*10e6).*(2);
% myOffload();