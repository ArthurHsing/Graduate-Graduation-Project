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