function [r] = setSystemConfig()
    global systemConfig;
    systemConfig.experimentTimes = 1; %实验次数
    %是否考虑信道波动
    systemConfig.isChannelWaved = 1;
    %模型每一部分的比例
    if ~systemConfig.isChannelWaved
        systemConfig.alpha = 1; %时延的影响因子
        systemConfig.beta = 0; %方差的影响因子
    else
        systemConfig.alpha = 1; %时延的影响因子
        systemConfig.beta = 0; %方差的影响因子       
        systemConfig.gamma = 0; %单独把时延提取出来
        systemConfig.delta = 0; %系统容量与传输时延的相关系数
        systemConfig.epsilon = 0; %系统容量与任务在设备上的平均完成时延的相关系数
        systemConfig.zeta = 0;
%         systemConfig.alpha = 0.8; %时延的影响因子
%         systemConfig.beta = 0; %方差的影响因子       
%         systemConfig.gamma = 0.2; %单独把时延提取出来
%         systemConfig.delta = 0; %系统容量与传输时延的相关系数
%         systemConfig.epsilon = 0; %系统容量与任务在设备上的平均完成时延的相关系数
        
%         systemConfig.alpha = 1; %时延的影响因子
%         systemConfig.beta = 0; %方差的影响因子       
%         systemConfig.gamma = 0; %单独把时延提取出来
%         systemConfig.delta = 0; %系统容量与传输时延的相关系数
%         systemConfig.epsilon = 0; %系统容量与任务在设备上的平均完成时延的相关系数

    end

%     systemConfig.alpha = 1; %时延的影响因子
%     systemConfig.beta = 0; %方差的影响因子
    %模拟退火的参数
    systemConfig.isAnnealing = 1; %是否采用模拟退火
%     systemConfig.T_annealing = 3e-5; %模拟退火的温度
    systemConfig.T_annealing =5e1; %模拟退火的温度
%     systemConfig.T_annealing = 5e-4; %模拟退火的温度
    systemConfig.alpha_annealing = 1; %模拟退火的降温系数

    %时间精度
    systemConfig.d = 4;
    %任务情况
%     systemConfig.taskSize = 3*10e6; % 3M bits·
    systemConfig.taskSize = 3*8*1024*1024; %3M byte
    systemConfig.taskComputationIntensityPerBit = 2; % 10cycles
    systemConfig.noArr = 50; %任务个数
    %设备情况
    systemConfig.deviceCPUFrequency = 1500e6; % 200MHz
    systemConfig.deviceNum = 10;% 设备个数
    systemConfig.deviceArrivalRate = ones(1, systemConfig.deviceNum).*15; %设备上的任务到达率
    [arrTimesAll, arrSrvTimeAll] = getArriveTimeAndSrvTime();
    systemConfig.arrTimesAll = arrTimesAll; %所有设备上的任务的到达间隔
    systemConfig.arrSrvTimeAll = arrSrvTimeAll; %所有设备上的任务的服务时间间隔
    %边缘服务器情况
    systemConfig.edgeCPUFrequency = 5e9; % 2GHz
    systemConfig.edgeNum = 5; %边缘服务器的个数; 
    % 云服务器情况
    systemConfig.cloudCPUFrequency = 10*10e9; %10GHz
    
    %无线信道配置
    if ~systemConfig.isChannelWaved
        %如果不考虑信道波动，无线信道的增益就是固定的，而且每条信道的增益都一样
        systemConfig.wireless.wireless_gains = ones(1, systemConfig.deviceNum); %各个设备与边缘节点的无线信道的信道增益
    else
        %如果考虑信道波动，那么无线信道的增益就不是固定的，而且每条信道的增益都不一样
        systemConfig.wireless.wireless_gain_parameter = 1; %瑞利分布的基本参数
        systemConfig.wireless.wireless_gains = raylrnd(ones(...
            1, systemConfig.deviceNum).*systemConfig.wireless.wireless_gain_parameter); %各个设备与边缘节点的无线信道的信道增益
    end    

    systemConfig.wireless.noisePower = 1e-2; %背景噪声功率 10e-2W
    systemConfig.wireless.transmissionPower = 1; %传输功率 1W
    systemConfig.wireless.bandWidth = 5*10e6; %带宽1MHz
    %有线信道配置
    systemConfig.wired.bandWidth = 500*10e6; %带宽10Mbps
    systemConfig.wired.metric = 20; %边缘服务器距离云服务的跳数，有10跳

    r = systemConfig;
end

