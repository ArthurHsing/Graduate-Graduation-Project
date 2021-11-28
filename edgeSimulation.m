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