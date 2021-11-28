%% 适应度函数表达式
function [fitness, fitnessRecord] = fitnessfun(capacity, systemConfig)
    % 初始化
    % 任务
    taskSize = systemConfig.taskSize;
    taskComputationIntensityPerBit = systemConfig.taskComputationIntensityPerBit;
    % 设备
    deviceCPUFrequency = systemConfig.deviceCPUFrequency;
    deviceNum = systemConfig.deviceNum;
    deviceArrivalRate = systemConfig.deviceArrivalRate;
    deviceArrivalRate_Sum = sum(deviceArrivalRate);
    % 边缘服务器
    edgeCPUFrequency = systemConfig.edgeCPUFrequency;
    c_Edge = systemConfig.edgeNum;
    % 云服务器
    cloudCPUFrequency = systemConfig.cloudCPUFrequency;
    % 无线信道参数
    wireless = systemConfig.wireless;
    wireless_gains = wireless.wireless_gains;
    % 有线信道参数
    wired = systemConfig.wired;
    
    % devicesCapacity, edgeCapacity分别为设备上的排队系统和边缘节点上的排队系统的容量取值范围
    devicesCapacity = capacity(1, 1 : deviceNum); %设备层上各设备的排队系统容量的取值范围
    edgeCapacity = capacity(1, deviceNum + 1); %边缘节点层的排队系统的容量的取值范围
    
    %设备上的任务到达率，每个设备可以不一样，这只是基础值（待定）
%     ar_Device_Base = 10; 
    %每个任务需要的总的计算强度
    taskComputationIntensity = taskSize*taskComputationIntensityPerBit;
    %设备上的任务服务率，通过计算得到
    sr_Device = deviceCPUFrequency/taskComputationIntensity;
    %边缘节点上单个服务器的服务率
    sr_Edge = edgeCPUFrequency/taskComputationIntensity;
    %云节点的服务率
    sr_Cloud = cloudCPUFrequency/taskComputationIntensity;

    Ws_Device = 0;
    wirelessTT = 0;
    ar_Edge = 0; %记录各设备卸载到边缘节点的任务到达率之和
    PN_Devices_average = 0; %设备上总的任务卸载率
    for i = 1:1:deviceNum
        ar_Device = deviceArrivalRate(i); %设备上的任务到达率（处理方式待定，主要是想处理成每个设备上的任务到达率都不一样）
        [Ws_Device_Per, PN_Device] = PerDeviceWs(devicesCapacity(i), ar_Device, sr_Device);
        [wirelessTTPer] = wirelessTTFun(taskSize, PN_Device, wireless, wireless_gains(i));
        if wirelessTTPer == inf
            disp('too big');
        end
        ar_Edge = ar_Edge + ar_Device * PN_Device;
        PN_Devices_average = PN_Devices_average + PN_Device.*(ar_Device./deviceArrivalRate_Sum);
%         devicesRecord(i, :) = [Ws_Device_Per, ar_Device, PN_Device, wirelessTTPer];
        Ws_Device = Ws_Device + Ws_Device_Per.*(1 - PN_Device).*(ar_Device./deviceArrivalRate_Sum);
        wirelessTT = wirelessTT + wirelessTTPer.*PN_Device.*(ar_Device./deviceArrivalRate_Sum);
    end
    % 边缘节点上的逗留时间计算
    [Ws_Edge, PN_Edge, sr_Edge, it_Edge, P0_Edge] = EdgeWs(edgeCapacity, ar_Edge, sr_Edge, c_Edge, PN_Devices_average);
    % 边缘节点->云节点有线信道的传输时延计算
    [wiredTT] = wiredTTFun(taskSize, PN_Edge, wired, PN_Devices_average);
    % 云节点上的逗留时间计算
    [Ws_Cloud] =  CloudWs(ar_Edge, PN_Edge, sr_Cloud, PN_Devices_average);
    % 适应度函数即总的逗留时间计算
    fitness = Ws_Device + Ws_Edge + Ws_Cloud + wirelessTT + wiredTT;
    fitnessRecord.Ws_Device = Ws_Device;
    fitnessRecord.Ws_Edge = Ws_Edge;
    fitnessRecord.Ws_Cloud = Ws_Cloud;
    fitnessRecord.wirelessTT = wirelessTT;
    fitnessRecord.wiredTT = wiredTT;
    fitnessRecord.ar_Edge = ar_Edge;
    fitnessRecord.ar_Cloud = ar_Edge * PN_Edge;
    fitnessRecord.PN_Devices_average = PN_Devices_average;
    fitnessRecord.PN_Edge = PN_Edge;
    fitnessRecord.P0_Edge = P0_Edge;
    fitnessRecord.wireless_gains = wireless_gains;
    fitnessRecord.it_Edge = it_Edge;
    fitnessRecord.c_Edge = capacity(end);
end
%% 每个设备上的逗留时间计算，函数封装
%N_Device设备的容量，ar_Device设备上的任务到达率（待定）
function [Ws_Device, PN_Device] = PerDeviceWs(N_Device, ar_Device, sr_Device)
    Ls_Device = 0; %初始化设备上任务的队长
    it_Device = ar_Device./sr_Device; %设备上的服务强度
    if it_Device == 1   %M/M/1/N到达率为1的情况需要单独讨论
        Ls_Device = N_Device./2;
        P0_Device = 1./(N_Device+1);
    else
        P0_Device = (1-it_Device)./(1-it_Device.^(N_Device + 1)); %设备的排队系统上没有任务的概率
        %根据M/M/1/N的队长公式来计算队长, 这个for循环就是表示的求和
        for n = 1:1:N_Device
            Pn_Device = P0_Device*it_Device.^n; %设备的排队系统上有n个任务的概率
            Lsn = n*Pn_Device;
            Ls_Device = Ls_Device + Lsn;
        end
    end
    PN_Device = P0_Device*(it_Device.^N_Device);
    Ws_Device = Ls_Device./(sr_Device.*(1-P0_Device));
%     if N_Device == 10
%         disp('debug');
%     end
end
%% 设备->边缘节点 无线信道上的传输时间
function [wirelessTTPer] = wirelessTTFun(taskSize, PN_Device, wireless, gain)
    np = wireless.noisePower;   % 噪声功率
    tp = wireless.transmissionPower; %传输功率
    bw = wireless.bandWidth; %带宽
%     gain = raylrnd(0.5); %生成服从瑞利分布的信道增益
%     gain = 1;
    % 根据香农公式得到传输速率
    rate = bw*log2(gain*tp/np);
    if rate <= 0
        wirelessTTPer = +Inf;
    else 
        %得到任务在无线信道上的传输时延期望
        wirelessTTPer = taskSize./rate;    
    end
%     if wirelessTTPer < 0
%         disp('something wrong：wirelessTTPer');
%     end
end
%% 边缘节点上的逗留时间计算，函数封装
function [Ws_Edge, PN_Edge, sr_Edge, it_Edge, P0_Edge] = EdgeWs(N_Edge, ar_Edge, sr_Edge, c_Edge, PN_Devices_average)
    it_Edge = ar_Edge/(c_Edge*sr_Edge);
%     disp(it_Edge);
    if it_Edge > 10
        disp('debug');
    end
    % 边缘节点的排队系统有0个任务的概率
    %分母的第一部分计算
    P0_Edge_Denominator_Part1 = 0;
    for k = 0:1:c_Edge
        P0_Edge_Denominator_Part1 = P0_Edge_Denominator_Part1 + ((c_Edge*it_Edge).^k)./factorial(k);
    end
    %分母的第二部分计算
    P0_Edge_Denominator_Part2 = ((c_Edge.^c_Edge)./factorial(c_Edge))*(it_Edge*(it_Edge.^c_Edge - it_Edge.^N_Edge)/(1-it_Edge));
    %分母
    P0_Edge_Denominator = P0_Edge_Denominator_Part1 + P0_Edge_Denominator_Part2;
    %完整表示
    P0_Edge = 1 / P0_Edge_Denominator;
    Lq_Edge_LeftPart = (P0_Edge*it_Edge*(c_Edge*it_Edge).^c_Edge)/(factorial(c_Edge)*(1-it_Edge).^2);
    nsc = N_Edge-c_Edge;%没有物理意义，因为公式中用到的地方太多，就单独表示出来
    Lq_Edge_RightPart = 1-(it_Edge.^nsc)-nsc.*(it_Edge.^nsc)*(1-it_Edge);
    %完整表示
    Lq_Edge = Lq_Edge_LeftPart * Lq_Edge_RightPart;
    PN_Edge = ((c_Edge.^c_Edge)/factorial(c_Edge)).*(it_Edge.^N_Edge)*P0_Edge;
    
    Ws_Edge = Lq_Edge/(ar_Edge*(1-PN_Edge)) + 1/sr_Edge;
    Ws_Edge = PN_Devices_average.*(1 - PN_Edge).*Ws_Edge;
    if isnan(Ws_Edge)
        disp('something wrong with Ws_Edge');
    end
end
%% 边缘节点->云节点 有线信道上的传输时间
function [wiredTT] = wiredTTFun(taskSize, PN_Edge, wired, PN_Devices_average)
    bw = wired.bandWidth; %带宽
    metric = wired.metric;   % 跳数
    %得到任务在无线信道上的传输时延期望
    wiredTT = ((taskSize/bw)*PN_Devices_average*PN_Edge)*metric;
    if wiredTT < 0
        disp('something wrong：wiredTT');
    end
end
%% 云节点上的逗留时间计算，函数封装
function [Ws_Cloud] = CloudWs(ar_Edge, PN_Edge, sr_Cloud, PN_Devices_average)
    ar_Cloud = ar_Edge.*PN_Edge; %云节点上的任务到达率
%     if sr_Cloud > ar_Cloud
%         disp(sr_Cloud);
%         disp(ar_Cloud);
%     end;
    if sr_Cloud < ar_Cloud %M/M/1/∞的到达率不能大于服务率，否则会造成队列无限长的情况
        Ws_Cloud = +Inf;
        return;
    end
    Ws_Cloud = 1./(sr_Cloud - ar_Cloud); 
end