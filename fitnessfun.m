%% 适应度函数表达式
function [fitness, fitnessRecord] = fitnessfun(capacity)
    global systemConfig;
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
%     wireless_gains = wireless.wireless_gains;
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
    
    finishTimePerDevice = zeros(1, deviceNum); %记录每一个设备的任务平均完成时间，用于后面计算任务完成时间的方差
    finishTimePerDeviceWithoutWireless = zeros(1, deviceNum);
    finishTimePerDeviceWithoutEdgeCloud = zeros(1, deviceNum);
    offloadNum_PerDevice = zeros(1, deviceNum); %记录每一个设备卸载的任务数
    wirelessTT_PerDevice = zeros(1, deviceNum); %记录每一个设备到边缘节点的无线传输时延
    wirelessTT_PerDevice_WithWeight = zeros(1, deviceNum);
    PN_Devices_Per = zeros(1, deviceNum);
    for i = 1:1:deviceNum
        ar_Device = deviceArrivalRate(i); %设备上的任务到达率（处理方式待定，主要是想处理成每个设备上的任务到达率都不一样）
        [Ws_Device_Per, PN_Device] = PerDeviceWs(devicesCapacity(i), ar_Device, sr_Device);
        [wirelessTTPer] = wirelessTTFun(taskSize, wireless, i);
        if wirelessTTPer == inf
            disp('too big');
        end
        PN_Devices_Per(i) = PN_Device;
        finishTimePerDeviceWithoutWireless(i) = Ws_Device_Per;
        finishTimePerDevice(i) = Ws_Device_Per + wirelessTTPer;
        ar_Edge_cur = ar_Device * PN_Device;
        ar_Edge = ar_Edge + ar_Edge_cur;
        offloadNum_PerDevice(i) = ar_Edge_cur;
        PN_Devices_average = PN_Devices_average + PN_Device.*(ar_Device./deviceArrivalRate_Sum);
%         devicesRecord(i, :) = [Ws_Device_Per, ar_Device, PN_Device, wirelessTTPer];
        Ws_Device = Ws_Device + Ws_Device_Per.*(1 - PN_Device).*(ar_Device./deviceArrivalRate_Sum);
%         Ws_Device = Ws_Device + Ws_Device_Per.*(ar_Device./deviceArrivalRate_Sum);
        
        wirelessTT = wirelessTT + wirelessTTPer.*PN_Device.*(ar_Device./deviceArrivalRate_Sum);
        wirelessTT_PerDevice(i) = wirelessTTPer;
        wirelessTT_PerDevice_WithWeight(i) = wirelessTTPer.*PN_Device.*(ar_Device./deviceArrivalRate_Sum);
    end
    if isnan(ar_Edge)
        disp('debug');
    end
    % 边缘节点上的逗留时间计算
    [Ws_Edge, PN_Edge, it_Edge, P0_Edge] = EdgeWs(edgeCapacity, ar_Edge, sr_Edge, c_Edge, PN_Devices_average);
    % 边缘节点->云节点有线信道的传输时延计算
    [wiredTT] = wiredTTFun(taskSize, PN_Edge, wired, PN_Devices_average);
    % 云节点上的逗留时间计算
    [Ws_Cloud] =  CloudWs(ar_Edge, PN_Edge, sr_Cloud, PN_Devices_average);
    finishTimePerDeviceWithoutEdgeCloud = finishTimePerDevice;
    finishTimePerDevice = finishTimePerDevice + (offloadNum_PerDevice ./ (ar_Edge./deviceNum)).*(Ws_Edge + wiredTT + Ws_Cloud);
    finishTime = Ws_Device + Ws_Edge + Ws_Cloud + wirelessTT + wiredTT;
    Ws_Std = std(finishTimePerDevice); %计算每个设备任务完成时延的标准差
    if ~systemConfig.isChannelWaved
%         correlationMatrix = corrcoef(devicesCapacity, wirelessTT_PerDevice);
%         correlation = correlationMatrix(1, 2);
        % 适应度函数即总的逗留时间计算
        fitness = systemConfig.alpha .* finishTime + systemConfig.beta .* Ws_Std;
    else
%         correlationMatrix = corrcoef(devicesCapacity, wirelessTT_PerDevice);
%         correlationMatrix = corrcoef(devicesCapacity, wirelessTT_PerDevice);
%         correlation = correlationMatrix(1, 2);
%         correlation = corr(1./devicesCapacity', wirelessTT_PerDevice', 'Type', 'Pearson');
        correlation_delta = corr(1./devicesCapacity', wirelessTT_PerDevice', 'Type', 'Spearman');
        correlation_delta_1 = corr(devicesCapacity', wirelessTT_PerDevice', 'Type', 'Spearman');
        correlation_epsilon = corr(1./finishTimePerDeviceWithoutWireless', wirelessTT_PerDevice', 'Type', 'Spearman');
%         if correlation_delta > -0.5 
%             fitness = Inf;
%         else
            if isnan(correlation_delta)
                [~, maxIndex] = max(wirelessTT_PerDevice);
                devicesCapacity(maxIndex) = devicesCapacity(maxIndex) + 1;
                correlation_delta = corr(1./devicesCapacity', wirelessTT_PerDevice', 'Type', 'Spearman');
%                 correlation_delta = 0;
            end
            fitness = ...
                systemConfig.alpha .* finishTime;...
                systemConfig.beta .* Ws_Std + ...
                systemConfig.gamma .* wirelessTT + ...
                systemConfig.delta .* correlation_delta + ...
...%                 systemConfig.epsilon .* correlation_epsilon + ...
                systemConfig.zeta .* wiredTT;
%         end
%         spearmanCorrelation = 
%         fitness = systemConfig.alpha .* finishTime + systemConfig.beta .* Ws_Std + systemConfig.gamma .* correlation;

          if isnan(fitness)
              disp('debug');
          end
    end
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
    fitnessRecord.wireless_gains = systemConfig.wireless.wireless_gains;
    fitnessRecord.it_Edge = it_Edge;
    fitnessRecord.c_Edge = capacity(end);
    fitnessRecord.fitness = fitness;
    fitnessRecord.finishTime = finishTime;
    fitnessRecord.Ws_Std = Ws_Std;
    if systemConfig.isChannelWaved
         fitnessRecord.correlation_delta = correlation_delta;
        fitnessRecord.correlation_delta_1 = correlation_delta_1;
        fitnessRecord.correlation_epsilon = correlation_epsilon;
    end
    fitnessRecord.wirelessTT_PerDevice = wirelessTT_PerDevice;
    fitnessRecord.finishTimePerDevice = finishTimePerDevice;
    fitnessRecord.finishTimePerDeviceWithoutEdgeCloud = finishTimePerDeviceWithoutEdgeCloud;
    fitnessRecord.wirelessTT_PerDevice_WithWeight = wirelessTT_PerDevice_WithWeight;
    fitnessRecord.finishTimePerDeviceWithoutWireless = finishTimePerDeviceWithoutWireless;
    fitnessRecord.PN_Devices_Per = PN_Devices_Per;
    fitnessRecord.capacity = capacity;
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
function [wirelessTTPer] = wirelessTTFun(taskSize, wireless, i)
    global systemConfig; % 这个全局变量的引入，主要为了方便修改传输速率为负数的情况
    gain = wireless.wireless_gains(i);
    np = wireless.noisePower;   % 噪声功率
    tp = wireless.transmissionPower; %传输功率
    bw = wireless.bandWidth; %带宽
%     gain = raylrnd(0.5); %生成服从瑞利分布的信道增益
%     gain = 1;
    % 根据香农公式得到传输速率
    rate = bw*log2(gain*tp/np);
    % 处理传输速率小于0的情况
    while rate <= 0
        systemConfig.wireless.wireless_gains(i) = raylrnd(systemConfig.wireless.wireless_gain_parameter);
        wireless = systemConfig.wireless;
        gain = wireless.wireless_gains(i);
        rate = bw*log2(gain*tp/np);
    end 
    %得到任务在无线信道上的传输时延期望
    wirelessTTPer = taskSize./rate;    
%     if wirelessTTPer < 0
%         disp('something wrong：wirelessTTPer');
%     end
end
%% 边缘节点上的逗留时间计算，函数封装
function [Ws_Edge, PN_Edge, it_Edge, P0_Edge] = EdgeWs(N_Edge, ar_Edge, sr_Edge, c_Edge, PN_Devices_average)
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
    Ws_Edge = PN_Devices_average.*(1 - PN_Edge).*Ws_Edge; %在边缘节点上计算的任务占多少比例，平均时间就要乘以这个比例
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
    Ws_Cloud = PN_Devices_average.*PN_Edge.*Ws_Cloud; %要乘上到达云服务器的任务的比例
end