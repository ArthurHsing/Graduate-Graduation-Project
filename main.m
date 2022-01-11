clear all;close all;clc;
setSystemConfig();
global bestOffloadNumResult;
global systemConfig;
global bestOffloadNumResult_BOA;
% systemConfig.taskSize = 2*8*1024*1024; % 1M bits
% systemConfig.taskSize = 1.8*8*1024*1024; % 1M bits
% [arrTimesAll, arrSrvTimeAll] = getArriveTimeAndSrvTime();
% systemConfig.arrTimesAll = arrTimesAll; %所有设备上的任务的到达间隔
% systemConfig.arrSrvTimeAll = arrSrvTimeAll; %所有设备上的任务的服务时间间隔

% getStrategy();

% systemConfig.wireless.wireless_gains = ones(1, systemConfig.deviceNum); %各个设备与边缘节点的无线信道的信道增益
% changeRateResultArr = struct([]);

% % 第一个点做三组实验，每一个实验改变无线信道的传输速率（任务到达率的改变）
% for m = 1:3
%     systemConfig.wireless.bandWidth = m*10e6; %带宽kMHz
%     % 做多次实验求平均——任务到达率的变化
%     for i = 1:systemConfig.experimentTimes
%         changeRateResultArr(i).arriveRateChange = arriveRateChange(); %任务到达率的改变
%     end
%     changeRateResult = getAverageOfSeveralExperimentTimes(changeRateResultArr);
%     % [changeRateResult] = arriveRateChange(); %任务到达率的改变
%     arriveRateChange_draw(changeRateResult, m, 0); %画图
% end

% 第一个点做三组实验，每一个实验改变无线信道的传输速率（任务体积的改变）
% for n = 1:3
%     systemConfig.wireless.bandWidth = n*10e6; %带宽nMHz
%     % 做多次实验求平均——任务体积的变化
%     for j = 1:systemConfig.experimentTimes
%         changeTaskSizeResultArr(j).changeTaskSize = taskSizeChange(); %任务体积的改变
%     end
%     changeTaskSizeResult = getAverageOfSeveralExperimentTimes(changeTaskSizeResultArr);
%     % [changeTaskSizeResult] = taskSizeChange(); %任务体积的改变
%     taskSizeChange_draw(changeTaskSizeResult, n, 0); %画图
% end

% 测试模拟退火改进HBA
% result = 0;
% corr_Aver = 0;
% max = 1;
% for q = 1 : max
%         systemConfig.wireless.wireless_gains = raylrnd(ones(...
%             1, systemConfig.deviceNum).*systemConfig.wireless.wireless_gain_parameter); %各个设备与边缘节点的无线信道的信道增益
%     getStrategy();
%     result = result + bestOffloadNumResult.finishTime .* (1/max);
%     bestOffloadNumResult.FRBest.correlation_delta
%     corr_Aver = corr_Aver + bestOffloadNumResult.FRBest.correlation_delta .* (1/max);
% end
% disp(result);
% disp(corr_Aver);


% [wirelessChannelChangeResult] = wirelessChannelChange(); %信道的波动
% wirelessChannelChange_draw(wirelessChannelChangeResult); %画图
% capacityResult = 

% systemConfig.taskSize = (1*10e6).*(2);
% myOffload();

%测试其它算法
getStrategy_BOA();

function [average]  = getAverageOfSeveralExperimentTimes(allTimes)
    experimentTypeCell = fieldnames(allTimes);
    experimentType = experimentTypeCell{1};
    resultStruct = struct([]);
    times = length(allTimes);
    for i = 1:1:length(allTimes)
        oneTimeResult = getfield(allTimes(i), experimentType);
        resultFieldsCell = fieldnames(oneTimeResult);
        for j = 1:1:length(resultFieldsCell)
            resultField = resultFieldsCell{j}; %字段名
            if i == 1
                resultStruct(1).(resultField) = struct([]);
            end
            subResult = getfield(oneTimeResult, resultField);
            subResultFieldsCell = fieldnames(subResult);
            for k = 1:1:length(subResultFieldsCell)
                subResultField = subResultFieldsCell{k};
                curTimeValArr = [allTimes(i).(experimentType).(resultField) .(subResultField)];
                if i == 1
                    tempCell = num2cell(curTimeValArr./times);
                    [resultStruct(1).(resultField)(1:length(curTimeValArr)).(subResultField)] = deal(tempCell{:});
                else
                    preAverageTimeVal = [resultStruct(1).(resultField)(1:length(curTimeValArr)).(subResultField)];
                    curAverageTimeVal = (curTimeValArr ./ times) + preAverageTimeVal;
                    tempCell = num2cell(curAverageTimeVal);                    
                    [resultStruct(1).(resultField)(1:length(curTimeValArr)).(subResultField)] = deal(tempCell{:});
                end
            end
        end
    end
    average = resultStruct;
end