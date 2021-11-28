clear all;close all;clc;

setSystemConfig();
[bestCapacity, FR] = getStrategy();
% 设备层仿真
deviceResultArr = deviceSimulation(bestCapacity(1, 1:end-1));
% 对设备层仿真得到的结果进行处理
offloadedTasksFromDevice = formatDeviceLeaveInfo(deviceResultArr);
% 边缘节点层进行仿真
edgeResultArr = edgeSimulation(bestCapacity(1, end), offloadedTasksFromDevice);
% 对边缘节点仿真得到的结果进行处理
offloadedTasksFromEdge = formatEdgeLeaveInfo(edgeResultArr);
% 云节点层进行仿真
cloudResultArr = cloudSimulation(offloadedTasksFromEdge);
% 计算平均完成时延
[averageCompletionTime, p_off_device, p_off_edge] = getAverageCompletionTime([deviceResultArr.arrTotalSysTime], edgeResultArr.arrTotalSysTime, cloudResultArr.arrTotalSysTime);
disp(['The simulation result is ', num2str(averageCompletionTime)]);
% 设备层仿真
function [deviceResultArr] = deviceSimulation(deviceCapacityArr)
    global systemConfig;
    qs = @queuesimulation;
    deviceResultArr = struct([]);
    deviceConfigInfo.type = 1;
    deviceConfigInfo.taskSize = systemConfig.taskSize;
    deviceConfigInfo.CPUFrequency = systemConfig.deviceCPUFrequency;
    deviceConfigInfo.computationIntensityPerBit = systemConfig.taskComputationIntensityPerBit;
    bw = systemConfig.wireless.bandWidth;
    np = systemConfig.wireless.noisePower;
    tp = systemConfig.wireless.transmissionPower;
    for i=1:1:length(deviceCapacityArr)
        deviceConfigInfo.systemCapacity = deviceCapacityArr(i);
        deviceConfigInfo.arrivalRate = systemConfig.deviceArrivalRate(i);
        deviceResult = qs(deviceConfigInfo);
        % 卸载的任务离开设备的时间
        deviceResultArr(end + 1).leaveTimeLine = deviceResult.leaveTimeLine;
        % 拿到信道增益
        gain = systemConfig.wireless.wireless_gains(i);
        % 计算出传输速率
        rate = bw*log2(gain*tp/np);
        %计算传输时延
        trDelay = systemConfig.taskSize./rate;
        % 记录卸载任务的传输时延
        deviceResultArr(end).wirelessTrDelay = ones(1, length(deviceResult.leaveTimeLine)).*trDelay;
        % 卸载的任务到达边缘节点的时间，要加上传输时延
%         deviceResultArr(end).arriveEdgeTimeline = deviceResult.leaveTimeLine;
        deviceResultArr(end).arriveEdgeTimeline = deviceResult.leaveTimeLine + trDelay;
        %卸载的任务的服务时间
        deviceResultArr(end).offloadedSrvTime = deviceResult.offloadedSrvTime;
        %未卸载的任务在设备上的执行时间
        deviceResultArr(end).arrTotalSysTime = deviceResult.arrTotalSysTime;
    end
end

% 边缘节点层仿真
function [edgeResultArr] = edgeSimulation(edgeCapacity, offloadedTasksFromDevice)
    global systemConfig;
    qs = @queuesimulation;
    edgeConfigInfo.type = 2;
    edgeConfigInfo.edgeNum = systemConfig.edgeNum;
    edgeConfigInfo.systemCapacity = edgeCapacity;
    edgeConfigInfo.offloadedTasksFromDevice = offloadedTasksFromDevice;
    edgeResultArr = qs(edgeConfigInfo);
    bw = systemConfig.wired.bandWidth; % 带宽
    metric = systemConfig.wired.metric; % 跳数
    %计算传输时延
    trDelay = (systemConfig.taskSize./bw).*metric;
    leaveTimeLine = edgeResultArr.leaveTimeLine;
    edgeResultArr.leaveTimeLine = leaveTimeLine + trDelay;
    edgeResultArr.wiredTrDelay = ones(1, length(edgeResultArr.leaveTimeLine)).*trDelay;
end

% 云节点仿真
function [cloudResultArr] = cloudSimulation(offloadedTasksFromEdge)
    qs = @queuesimulation;
    cloudConfigInfo.type = 3;
    cloudConfigInfo.cloudNum = 1;
    cloudConfigInfo.offloadedTasksFromEdge = offloadedTasksFromEdge;
    cloudResultArr = qs(cloudConfigInfo);
end
% 对设备层所有设备输出的任务进行处理
function[offloadedTasksFromDevice] = formatDeviceLeaveInfo(deviceResultArr)
    global systemConfig;
    frequencyRatio = systemConfig.deviceCPUFrequency./systemConfig.edgeCPUFrequency;
    mergeArriveEdgeTimeLine = [deviceResultArr.arriveEdgeTimeline];
    mergeLeaveSrvTime = [deviceResultArr.offloadedSrvTime];
    mergeWirelessTrDelay = [deviceResultArr.wirelessTrDelay];
    mergeArriveEdgeTimeLine = round(mergeArriveEdgeTimeLine, systemConfig.d);
    mergeLeaveSrvTime = round(mergeLeaveSrvTime.*frequencyRatio, systemConfig.d);
    mergeWirelessTrDelay = round(mergeWirelessTrDelay, systemConfig.d);
    if isempty(mergeArriveEdgeTimeLine) %没有卸载的任务，就按空处理
        leaveInfo = struct(...
        'arriveEdgeTimeLine', {},...
        'offloadedSrvTime', {},...
        'wirelessTrDelay', {}...
        );
    else %有卸载的任务，就正常处理
        leaveInfo = struct(...
        'arriveEdgeTimeLine', mat2cell(mergeArriveEdgeTimeLine, [1], ones(1, length(mergeArriveEdgeTimeLine))),... 
        'offloadedSrvTime', mat2cell(mergeLeaveSrvTime, [1], ones(1, length(mergeLeaveSrvTime))),...
        'wirelessTrDelay', mat2cell(mergeWirelessTrDelay, [1],  ones(1, length(mergeWirelessTrDelay)))...
        );    
    end
    [temp, index] = sort([leaveInfo.arriveEdgeTimeLine]);
    offloadedTasksFromDevice = leaveInfo(index);
end

% 对边缘层所有设备输出的任务进行处理
function[offloadedTasksFromEdge] = formatEdgeLeaveInfo(edgeResultArr)
    global systemConfig;
    frequencyRatio = systemConfig.edgeCPUFrequency./systemConfig.cloudCPUFrequency;
    arriveCloudTimeLine = edgeResultArr.leaveTimeLine;
    offloadedSrvTime = round(edgeResultArr.offloadedSrvTime.*frequencyRatio, systemConfig.d);
    wirelessTrDelayOffloaded = edgeResultArr.wirelessTrDelayOffloaded;
    wiredTrDelay = edgeResultArr.wiredTrDelay;
    if isempty(arriveCloudTimeLine) %没有卸载的任务，就按空处理
        offloadedTasksFromEdge = struct(...
        'arriveCloudTimeLine', {},...
        'offloadedSrvTime', {},...
        'wirelessTrDelay', {},...
        'wiredTrDelay', {}...
        );
    else %有卸载的任务，就正常处理
        offloadedTasksFromEdge = struct(...
        'arriveCloudTimeLine', mat2cell(arriveCloudTimeLine, [1], ones(1, length(arriveCloudTimeLine))),...
        'offloadedSrvTime', mat2cell(offloadedSrvTime, [1], ones(1, length(offloadedSrvTime))),...
        'wirelessTrDelay', mat2cell(wirelessTrDelayOffloaded, [1], ones(1, length(wirelessTrDelayOffloaded))),...
        'wiredTrDelay', mat2cell(wiredTrDelay, [1], ones(1, length(wiredTrDelay)))...
        );        
    end
end

function[averageCompletionTime, p_off_device, p_off_edge] = getAverageCompletionTime(deviceCompletionTimeArrs, edgeCompletionTimeArr, cloudCompletionTimeArr)
    averageCompletionTime = mean([deviceCompletionTimeArrs, edgeCompletionTimeArr, cloudCompletionTimeArr]);
    ld = length(deviceCompletionTimeArrs);
    le = length(edgeCompletionTimeArr);
    lc = length(cloudCompletionTimeArr);
    disp(ld + le + lc);
    p_off_device = (le + lc)/(ld + le + lc);
    p_off_edge = lc/(le + lc);
end