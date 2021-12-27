function [result] = arriveRateChange()
    global systemConfig;
    maxAr = 50;
%     X_ar = 1:1:maxAr;
    avrTime_MyOffload = [];
    pOffDevice_MyOffload = [];
    pOffEdge_MyOffload = [];
    avrTimeTheory_MyOffload = [];
    pOffDeviceTheory_MyOffload = [];
    pOffEdgeTheory_MyOffload = [];
    averageTime_Device_MyOffload = [];
    averageTime_Edge_MyOffload = [];
    averageTime_Cloud_MyOffload = [];
    avrTime_AllInDeviceOffload = [];
    avrTime_AllInEdgeOffload = [];
    avrTime_AllInCloudOffload = [];
    avrTime_RandomOffload = [];
    avrTime_MmssOffload = [];

    % 任务到达率的变化,从1变到30
    for ar = 5:5:maxAr
        systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*ar; %设备上的任务到达率
        % 每次改变任务到达率都需要更改，queuesimulation函数里面的参数
        [arrTimesAll, arrSrvTimeAll] = getArriveTimeAndSrvTime(); 
        systemConfig.arrTimesAll = arrTimesAll; %所有设备上的任务的到达间隔
        systemConfig.arrSrvTimeAll = arrSrvTimeAll; %所有设备上的任务的服务时间间隔
        % 策略卸载
        [averageCompletionTime_MyOffload, p_off_device, p_off_edge, FRBest, averageTime_Device, averageTime_Edge, averageTime_Cloud] = myOffload();
        avrTime_MyOffload(end + 1) = averageCompletionTime_MyOffload;
        pOffDevice_MyOffload(end + 1) = p_off_device;
        pOffEdge_MyOffload(end + 1) = p_off_edge;
        averageTime_Device_MyOffload(end + 1) = averageTime_Device;
        averageTime_Edge_MyOffload(end + 1) = averageTime_Edge;
        averageTime_Cloud_MyOffload(end + 1) = averageTime_Cloud;
        
        avrTimeTheory_MyOffload(end + 1) = FRBest.fitness;
        pOffDeviceTheory_MyOffload(end + 1) = FRBest.PN_Devices_average;
        pOffEdgeTheory_MyOffload(end + 1) = FRBest.PN_Edge;
        % 全在设备上进行计算
        [averageCompletionTime_AllInDeviceOffload] = allInDeviceOffload();
        avrTime_AllInDeviceOffload(end + 1) = averageCompletionTime_AllInDeviceOffload;
        % 全在边缘服务器上进行计算
        [averageCompletionTime_AllInEdgeOffload] = allInEdgeOffload();
        avrTime_AllInEdgeOffload(end + 1) = averageCompletionTime_AllInEdgeOffload;
        % 全在云服务器上进行计算
        [averageCompletionTime_AllInCloudOffload] = allInCloudOffload();
        avrTime_AllInCloudOffload(end + 1) = averageCompletionTime_AllInCloudOffload;   
        % 随机卸载
        [averageCompletionTime_RandomInCloudOffload] = randomOffload();
        avrTime_RandomOffload(end + 1) = averageCompletionTime_RandomInCloudOffload;  
        % 损失制卸载
        [averageCompletionTime_MmssOffload] = mmssOffload();
        avrTime_MmssOffload(end + 1) = averageCompletionTime_MmssOffload;        
    end
     avrTime = struct(...
        'myOffload', mat2cell(avrTime_MyOffload, [1], ones(1, length(avrTime_MyOffload))),...
        'allInDeviceOffload', mat2cell(avrTime_AllInDeviceOffload, [1], ones(1, length(avrTime_AllInDeviceOffload))),...
        'allInEdgeOffload', mat2cell(avrTime_AllInEdgeOffload, [1], ones(1, length(avrTime_AllInEdgeOffload))),...
        'allInCloudOffload', mat2cell(avrTime_AllInCloudOffload, [1], ones(1, length(avrTime_AllInCloudOffload))),...
        'mmssOffload', mat2cell(avrTime_MmssOffload, [1], ones(1, length(avrTime_MmssOffload))),...
        'randomOffload', mat2cell(avrTime_RandomOffload, [1], ones(1, length(avrTime_RandomOffload)))...
    );
    myOffloadSimulationData = struct(...
        'avrTime', mat2cell(avrTime_MyOffload, [1], ones(1, length(avrTime_MyOffload))),...
        'pOffDevice', mat2cell(pOffDevice_MyOffload, [1], ones(1, length(pOffDevice_MyOffload))),...
        'pOffEdge', mat2cell(pOffEdge_MyOffload, [1], ones(1, length(pOffEdge_MyOffload))),...
        'avrTimeDevice', mat2cell(averageTime_Device_MyOffload, [1], ones(1, length(averageTime_Device_MyOffload))),...
        'avrTimeEdge', mat2cell(averageTime_Edge_MyOffload, [1], ones(1, length(averageTime_Edge_MyOffload))),...
        'avrTimeCloud', mat2cell(averageTime_Cloud_MyOffload, [1], ones(1, length(averageTime_Cloud_MyOffload)))...
    );
    myOffloadTheoryData = struct(...
        'avrTime', mat2cell(avrTimeTheory_MyOffload, [1], ones(1, length(avrTimeTheory_MyOffload))),...
        'pOffDevice', mat2cell(pOffDeviceTheory_MyOffload, [1], ones(1, length(pOffDeviceTheory_MyOffload))),...
        'pOffEdge', mat2cell(pOffEdgeTheory_MyOffload, [1], ones(1, length(pOffEdgeTheory_MyOffload)))...
    );
    result = struct(...
        'avrTime',...
        avrTime,... 
        'myOffloadSimulationData',...
        myOffloadSimulationData,...
        'myOffloadTheoryData',...
        myOffloadTheoryData...
    );
end

