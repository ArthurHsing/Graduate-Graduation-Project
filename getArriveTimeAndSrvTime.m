function [arrTimesAll, arrSrvTimeAll] = getArriveTimeAndSrvTime()
    global systemConfig;
    arrTimesAll = ones(systemConfig.deviceNum, systemConfig.noArr);
    arrSrvTimeAll = ones(systemConfig.deviceNum, systemConfig.noArr);

    taskSize = systemConfig.taskSize;%任务大小
    CPUFrequency = systemConfig.deviceCPUFrequency;%CPU频率
    computationIntensityPerBit = systemConfig.taskComputationIntensityPerBit;%任务的服务强度
    computationIntensity = taskSize*computationIntensityPerBit;%每个任务需要的总的计算强度
    mu = CPUFrequency/computationIntensity; %服务率

    for i = 1:systemConfig.deviceNum
        lambda = systemConfig.deviceArrivalRate(i); %任务到达率
        arrTimesAll(i, :) = round((exprnd((1/lambda),...%到达率
                                     1,... % 行
                                     systemConfig.noArr)... %列
                                     +(10^-systemConfig.d)),... %误差
                                     systemConfig.d);%四舍五入

        arrSrvTimeAll(i, :) = round((exprnd((1/mu),... %服务率
                                     1,... %行
                                     systemConfig.noArr)... %列
                                     +(10^-systemConfig.d)),... %误差
                                     systemConfig.d); %四舍五入
    end
end