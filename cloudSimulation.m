% 云节点仿真
function [cloudResultArr] = cloudSimulation(offloadedTasksFromEdge)
    qs = @queuesimulation;
    cloudConfigInfo.type = 3;
    cloudConfigInfo.cloudNum = 1;
    cloudConfigInfo.offloadedTasksFromEdge = offloadedTasksFromEdge;
    cloudResultArr = qs(cloudConfigInfo);
end