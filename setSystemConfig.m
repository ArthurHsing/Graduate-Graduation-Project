function [r] = setSystemConfig()
    global systemConfig;
    %模型每一部分的比例
    systemConfig.alpha = 0.6; %时延的影响因子
    systemConfig.beta = 0.4; %方差的影响因子
%     systemConfig.alpha = 1; %时延的影响因子
%     systemConfig.beta = 0; %方差的影响因子
    %时间精度
    systemConfig.d = 4;
    %任务情况
    systemConfig.taskSize = 3*10e6; % 1M bits
    systemConfig.taskComputationIntensityPerBit = 4; % 10cycles
    systemConfig.noArr = 20; %任务个数
    %设备情况
    systemConfig.deviceCPUFrequency = 200*10e6; % 200MHz
    systemConfig.deviceNum = 20;% 设备个数
    systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*10; %设备上的任务到达率
    [arrTimesAll, arrSrvTimeAll] = getArriveTimeAndSrvTime();
    systemConfig.arrTimesAll = arrTimesAll; %所有设备上的任务的到达间隔
    systemConfig.arrSrvTimeAll = arrSrvTimeAll; %所有设备上的任务的服务时间间隔
    %边缘服务器情况
    systemConfig.edgeCPUFrequency = 1*10e9; % 2GHz
    systemConfig.edgeNum = 3; %边缘服务器的个数; 
    % 云服务器情况
    systemConfig.cloudCPUFrequency = 10*10e9; %10GHz
    %无线信道配置
    systemConfig.wireless.wireless_gains = ones(1, systemConfig.deviceNum); %各个设备与边缘节点的无线信道的信道增益
%     systemConfig.wireless.wireless_gain_parameter = 1; %瑞利分布的基本参数
%     systemConfig.wireless.wireless_gains = raylrnd(ones(...
%         systemConfig.wireless.wireless_gain_parameter, systemConfig.deviceNum)); %各个设备与边缘节点的无线信道的信道增益
    systemConfig.wireless.noisePower = 1e-2; %背景噪声功率 10e-2W
    systemConfig.wireless.transmissionPower = 1; %传输功率 1W
    systemConfig.wireless.bandWidth = 1*10e6; %带宽1MHz
    %有线信道配置
    systemConfig.wired.bandWidth = 200*10e6; %带宽10Mbps
    systemConfig.wired.metric = 20; %边缘服务器距离云服务的跳数，有10跳

    r = systemConfig;
end

