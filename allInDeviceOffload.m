function [averageCompletionTime] = allInDeviceOffload()
    global systemConfig;
    deviceResultArr = deviceSimulation(ones(1, systemConfig.deviceNum).*inf);
    averageCompletionTime = mean([deviceResultArr.arrTotalSysTime]);
    disp(['The simulation result is ', num2str(averageCompletionTime)]); 
end

