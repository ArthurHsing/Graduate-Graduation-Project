clear all;close all;clc;
setSystemConfig();


% [changeRateResult] = arriveRateChange(); %任务到达率的改变
% arriveRateChange_draw(changeRateResult); %画图

[changeTaskSizeResult] = taskSizeChange(); %任务到达率的改变
taskSizeChange_draw(changeTaskSizeResult); %画图

% global systemConfig;
% systemConfig.taskSize = (1*10e6).*(2);
% myOffload();