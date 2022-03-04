function [result] = wirelessChannelChange()
    global systemConfig;
    global arrTimesAllSave;
    global arrSrvTimeAllSave;
    global wirelessGainsSave;
    global wirelessIsFirstTime;
    global bestOffloadNumResult;
    global bestOffloadNumResult_BOA;
    global bestOffloadNumResult_PSO;
    global bestOffloadNumResult_CSA;
    global bestOffloadNumResult_GPC;
    maxAr = 10;
    avrTime_MyOffload = [];
    pOffDevice_MyOffload = [];
    pOffEdge_MyOffload = [];
    avrTimeTheory_MyOffload = [];
    pOffDeviceTheory_MyOffload = [];
    pOffEdgeTheory_MyOffload = [];
    avrTime_AllInDeviceOffload = [];
    avrTime_AllInEdgeOffload = [];
    avrTime_AllInCloudOffload = [];
    avrTime_RandomOffload = [];
    avrTime_MmssOffload = [];
    wlDelay_AllInEdgeOffload = [];
    avrWirelessChannelRate = [];
    
    avrTime_OriginHBA = [];
    avrTime_BOA = [];
    avrTime_CSA = [];
    avrTime_GPC = [];
    avrTime_PSO = [];
    
    correlation_my = [];
    correlation_OriginHBA = [];
    correlation_BOA = [];
    correlation_CSA = [];
    correlation_GPC = [];
    correlation_PSO = [];

    % 做10次实验，信道变化10次
    for ar = 1:maxAr
        if wirelessIsFirstTime
            systemConfig.wireless.wireless_gains = raylrnd(ones(...
                1, systemConfig.deviceNum).*systemConfig.wireless.wireless_gain_parameter); %各个设备与边缘节点的无线信道的信道增益
            wirelessGainsSave(ar, :) = systemConfig.wireless.wireless_gains;
            
            [arrTimesAll, arrSrvTimeAll] = getArriveTimeAndSrvTime(); 
            systemConfig.arrTimesAll = arrTimesAll; %所有设备上的任务的到达间隔
            systemConfig.arrSrvTimeAll = arrSrvTimeAll; %所有设备上的任务的服务时间间隔
            arrTimesAllSave = arrTimesAll;
            arrSrvTimeAllSave = arrSrvTimeAll;
        else
            systemConfig.wireless.wireless_gains = wirelessGainsSave(ar, :);
            systemConfig.arrTimesAll = arrTimesAllSave;
            systemConfig.arrSrvTimeAll = arrSrvTimeAllSave;
        end
%         avrWirelessChannelRate(end + 1) = getAverageWirelessChannelRate();
        %设置每个帧的任务都不一样
        [arrTimesAll, arrSrvTimeAll] = getArriveTimeAndSrvTime(); 
        systemConfig.arrTimesAll = arrTimesAll; %所有设备上的任务的到达间隔
        systemConfig.arrSrvTimeAll = arrSrvTimeAll; %所有设备上的任务的服务时间间隔
        % 策略卸载
        [averageCompletionTime_MyOffload, p_off_device, p_off_edge] = myOffload('O-HBA');
        avrTime_MyOffload(end + 1) = averageCompletionTime_MyOffload;
        pOffDevice_MyOffload(end + 1) = p_off_device;
        pOffEdge_MyOffload(end + 1) = p_off_edge;
        correlation_my(end + 1) = -bestOffloadNumResult.FRBest.correlation_delta;
        
        [averageCompletionTime_OriginHBA] = myOffload('HBA');
        avrTime_OriginHBA(end + 1) = averageCompletionTime_OriginHBA;
        correlation_OriginHBA(end + 1) = -bestOffloadNumResult.FRBest.correlation_delta;
        
        [averageCompletionTime_BOA] = myOffload('BOA');
        avrTime_BOA(end + 1) = averageCompletionTime_BOA;
        correlation_BOA(end + 1) = -bestOffloadNumResult_BOA.FRBest.correlation_delta;
        
%         [averageCompletionTime_CSA] = myOffload('CSA');
%         avrTime_CSA(end + 1) = averageCompletionTime_CSA;
%         correlation_CSA(end + 1) = -bestOffloadNumResult_CSA.FRBest.correlation_delta;
        
        [averageCompletionTime_GPC] = myOffload('GPC');
        avrTime_GPC(end + 1) = averageCompletionTime_GPC;
        correlation_GPC(end + 1) = -bestOffloadNumResult_GPC.FRBest.correlation_delta;
        
        [averageCompletionTime_PSO] = myOffload('PSO');
        avrTime_PSO(end + 1) = averageCompletionTime_PSO;
        correlation_PSO(end + 1) = -bestOffloadNumResult_PSO.FRBest.correlation_delta;
%         pOffDevice_OriginHBA(end + 1) = p_off_device_OriginHBA;
%         pOffEdge_OriginHBA(end + 1) = p_off_edge_OriginHBA;
%         avrTimeTheory_MyOffload(end + 1) = FRBest.fitness;
%         pOffDeviceTheory_MyOffload(end + 1) = FRBest.PN_Devices_average;
%         pOffEdgeTheory_MyOffload(end + 1) = FRBest.PN_Edge;
        % 全在设备上进行计算
        [averageCompletionTime_AllInDeviceOffload] = allInDeviceOffload();
        avrTime_AllInDeviceOffload(end + 1) = averageCompletionTime_AllInDeviceOffload;
%         % 全在边缘服务器上进行计算
%         [averageCompletionTime_AllInEdgeOffload, wireLessDelay_AllInEdgeOffload] = allInEdgeOffload();
%         avrTime_AllInEdgeOffload(end + 1) = averageCompletionTime_AllInEdgeOffload;
%         wlDelay_AllInEdgeOffload(end + 1) = wireLessDelay_AllInEdgeOffload;
%         % 全在云服务器上进行计算
%         [averageCompletionTime_AllInCloudOffload] = allInCloudOffload();
%         avrTime_AllInCloudOffload(end + 1) = averageCompletionTime_AllInCloudOffload;   
        % 随机卸载
        [averageCompletionTime_RandomInCloudOffload] = randomOffload();
        avrTime_RandomOffload(end + 1) = averageCompletionTime_RandomInCloudOffload;  
        % 损失制卸载
        [averageCompletionTime_MmssOffload] = mmssOffload();
        avrTime_MmssOffload(end + 1) = averageCompletionTime_MmssOffload;        
    end
     avrTime = struct(...
        'myOffload', mat2cell(avrTime_MyOffload, [1], ones(1, length(avrTime_MyOffload))),...
        'originHBA',mat2cell(avrTime_OriginHBA, [1], ones(1, length(avrTime_OriginHBA))),...
        'BOA',mat2cell(avrTime_BOA, [1], ones(1, length(avrTime_BOA))),...
...%         'CSA',mat2cell(avrTime_CSA, [1], ones(1, length(avrTime_CSA))),...
        'GPC',mat2cell(avrTime_GPC, [1], ones(1, length(avrTime_GPC))),...
        'PSO',mat2cell(avrTime_PSO, [1], ones(1, length(avrTime_PSO))),...
        'allInDeviceOffload', mat2cell(avrTime_AllInDeviceOffload, [1], ones(1, length(avrTime_AllInDeviceOffload))),...
...%         'allInEdgeOffload', mat2cell(avrTime_AllInEdgeOffload, [1], ones(1, length(avrTime_AllInEdgeOffload))),...
...%         'allInCloudOffload', mat2cell(avrTime_AllInCloudOffload, [1], ones(1, length(avrTime_AllInCloudOffload))),...
        'mmssOffload', mat2cell(avrTime_MmssOffload, [1], ones(1, length(avrTime_MmssOffload))),...
        'randomOffload', mat2cell(avrTime_RandomOffload, [1], ones(1, length(avrTime_RandomOffload)))...
    );
    correlation = struct(...
        'myOffload', mat2cell(correlation_my, [1], ones(1, length(correlation_my))),...
        'originHBA',mat2cell(correlation_OriginHBA, [1], ones(1, length(correlation_OriginHBA))),...
        'BOA',mat2cell(correlation_BOA, [1], ones(1, length(correlation_BOA))),...
...%         'CSA',mat2cell(correlation_CSA, [1], ones(1, length(correlation_CSA))),...
        'GPC',mat2cell(correlation_GPC, [1], ones(1, length(correlation_GPC))),...
        'PSO',mat2cell(correlation_PSO, [1], ones(1, length(correlation_PSO)))...
    );
    myOffloadSimulationData = struct(...
        'avrTime', mat2cell(avrTime_MyOffload, [1], ones(1, length(avrTime_MyOffload))),...
        'pOffDevice', mat2cell(pOffDevice_MyOffload, [1], ones(1, length(pOffDevice_MyOffload))),...
        'pOffEdge', mat2cell(pOffEdge_MyOffload, [1], ones(1, length(pOffEdge_MyOffload)))...
    );
%     myOffloadTheoryData = struct(...
%         'avrTime', mat2cell(avrTimeTheory_MyOffload, [1], ones(1, length(avrTimeTheory_MyOffload))),...
%         'pOffDevice', mat2cell(pOffDeviceTheory_MyOffload, [1], ones(1, length(pOffDeviceTheory_MyOffload))),...
%         'pOffEdge', mat2cell(pOffEdgeTheory_MyOffload, [1], ones(1, length(pOffEdgeTheory_MyOffload)))...
%     );
%     allInEdgeData = struct(...
%         'avrTime', mat2cell(avrTime_AllInEdgeOffload, [1], ones(1, length(avrTime_AllInEdgeOffload))),...
%         'wlDelay', mat2cell(wlDelay_AllInEdgeOffload, [1], ones(1, length(wlDelay_AllInEdgeOffload)))...
%     );
    result = struct(...
        'avrTime',...
        avrTime,... 
        'correlation',...
        correlation,... 
        'myOffloadSimulationData',...
        myOffloadSimulationData...
...%         'myOffloadTheoryData',...
...%         myOffloadTheoryData,...
...%         'allInEdgeData',...
...%         allInEdgeData,...
...%         'avrWirelessChannelRate',...
...%         avrWirelessChannelRate...
    );
end
