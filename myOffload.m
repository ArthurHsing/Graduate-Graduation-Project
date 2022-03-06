function [averageCompletionTime, p_off_device, p_off_edge, FRBest, averageTime_Device, averageTime_Edge, averageTime_Cloud] = myOffload(type)
    global systemConfig;
    systemConfig.isAnnealing = 0;
    FRBest = '写多了';
    switch type
        case 'O-HBA'
             systemConfig.isAnnealing = 1; %是否采用模拟退火
            [bestCapacity] = getStrategy();
        case 'HBA'
            systemConfig.isAnnealing = 0;
            [bestCapacity] = getStrategy();
        case 'BOA'
            [bestCapacity] = getStrategy_BOA();
        case 'CSA'
            [bestCapacity] = getStrategy_CSA();
        case 'GPC'
            [bestCapacity] = getStrategy_GPC();        
        case 'PSO'
            [bestCapacity] = getStrategy_PSO();     
        otherwise
            disp('debug');
    end

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
    [averageCompletionTime, p_off_device, p_off_edge, averageTime_Device, averageTime_Edge, averageTime_Cloud] = getAverageCompletionTime([deviceResultArr.arrTotalSysTime], edgeResultArr.arrTotalSysTime, cloudResultArr.arrTotalSysTime);
    disp(['The simulation result is ', num2str(averageCompletionTime)]); 
end