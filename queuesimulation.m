function [result] = queuesimulation(configInfo)
% % % % % Initializations
srvingState = [];
arrTotalSysTime = [];
arrWaitTime = [];
leaveTimeLine = [];%离开时间点
offloadedSrvTime = [];%记录离开任务的服务时间
noQueueVector = [];%记录系统中正在排队的任务的数组
noSysVector = [];%记录系统中总的任务的数组

iArr = 1; %下标，现在在处理第几个任务
iState = 0; %下标，理解为第几个时间的下标
state = 0; %当前系统中有多少个任务
d = 4; %步长指数，精确到毫秒
step = 10^-d; 
tolerance = 10^-(d+1);

concurrence = 0; %是否并发
% rho = lambda/mu;
% type，1：设备，2：边缘节点，3：云节点
if configInfo.type == 1
    noArr = 20; %一共有多少个任务
    m = 1;%服务器数量
    k = configInfo.systemCapacity;%系统容量
    taskSize = configInfo.taskSize;%任务大小
    CPUFrequency = configInfo.CPUFrequency;%CPU频率
    computationIntensityPerBit = configInfo.computationIntensityPerBit;%任务的服务强度
    computationIntensity = taskSize*computationIntensityPerBit;%每个任务需要的总的计算强度
    mu = CPUFrequency/computationIntensity; %服务率
    lambda = configInfo.arrivalRate; %任务到达率
    
    arrTimes = round((exprnd((1/lambda),1,noArr)+(10^-d)),d);%noArr个任务的到达时间间隔
    arrTimeline = cumsum(arrTimes);%加起来就是noArr个任务分别的到达时间线
    arrSrvTime = round((exprnd((1/mu),1,noArr)+(10^-d)),d);%noArr个任务的服务时间
end

if configInfo.type == 2
    m = configInfo.edgeNum; %边缘服务器的数量
    k = configInfo.systemCapacity; %系统容量
    arrTimeline = [configInfo.offloadedTasksFromDevice.arriveEdgeTimeLine]; %卸载到边缘服务器的各任务的到达时间
    arrSrvTime = [configInfo.offloadedTasksFromDevice.offloadedSrvTime]; %卸载到边缘服务器的各任务服务时间时间  
    wirelessTrDelay = [configInfo.offloadedTasksFromDevice.wirelessTrDelay]; %卸载到边缘服务器的各任务无线信道传输时延  
    wirelessTrDelayOffloaded = []; %用于保存从边缘服务器卸载到云节点的任务的无线信道传输时延，以供在云节点计算总的任务完成时延用
end

if configInfo.type == 3
    m = configInfo.cloudNum; %云服务器的数量
    k = inf; %云服务器的系统容量为无穷大
    arrTimeline = [configInfo.offloadedTasksFromEdge.arriveCloudTimeLine]; %卸载到云节点的各任务的到达时间
    arrSrvTime = [configInfo.offloadedTasksFromEdge.offloadedSrvTime]; %卸载到云节点的各任务的服务时间    
    wirelessTrDelay = [configInfo.offloadedTasksFromEdge.wirelessTrDelay]; %各任务从设备层卸载到边缘节点层的无线信道传输时延
    wiredTrDelay = [configInfo.offloadedTasksFromEdge.wiredTrDelay]; %各任务从边缘层卸载到云节点层的有线信道传输时延
end

if isempty(arrTimeline) %没有任务的情况，直接返回空就可以了
    if configInfo.type == 1
        result.leaveTimeLine = leaveTimeLine;
        result.offloadedSrvTime = offloadedSrvTime;
        result.arrTotalSysTime = arrTotalSysTime;
    elseif configInfo.type == 2
        result.leaveTimeLine = leaveTimeLine;
        result.offloadedSrvTime = offloadedSrvTime;
        result.arrTotalSysTime = arrTotalSysTime;
        result.wirelessTrDelayOffloaded = wirelessTrDelayOffloaded;
    else % type = 3
        result.arrTotalSysTime = arrTotalSysTime;
    end
    return
end

timeLine = 0:step:ceil(arrTimeline(end));%离散的横轴，每个横轴的间距是step，横轴的长度仍然是刚刚生成的任务时间线的长度
server(1:m) = 0;check = [];



i = 0;
while i < ceil(arrTimeline(end)) || i == ceil(arrTimeline(end))
    if ~concurrence % 并发的情况下不进行处理
        srvingState = srvingState - step;
        %server记录的是各服务器距离空闲还剩多少时间，因为每一次循环就相当于经过了step这么长的时间，所以要减去step
        server = server - step;
    
        %如果减完了发现距离空闲所剩的时间为负了，那说明该服务器上没有待处理的任务了，也就是服务器已经空闲了
        for iServer=1:m
            if(server(iServer)<0)
                server(iServer) = 0;
            end
        end
    end
    %记录下每一时刻服务器的状态
    monitor(iState+1,:) = server;

    %这是边界处理，在循环的末尾估计会用到这个
    if(iArr>length(arrTimeline))
        iArr = length(arrTimeline);
        break;
    end
    

    % i可以理解为是时间线，它以步长step在增加
    % 这里可以理解为当第iArr个任务已经到了，估计是因为浮点数不好做相等比较，所以这里用了一个tolerance误差来表示
    % 之前在JS中我也用过类似的表示方法
    isTaskArrived = abs(i-arrTimeline(iArr))<tolerance;
    if(isTaskArrived)
        % 当前任务的服务时间
        iArrSrvTime = arrSrvTime(iArr);
        %放在本地进行计算
        % 任务来了，系统中任务的个数就需要+1了
        state = state + 1;
        % 拿到当前较为空闲的服务器
        [minVal, minIndex] = min(server);
        % 随机卸载策略
        isRandomOffload = k < 0 && rand < 0.5;
        % 随机卸载，或者按系统容量来卸载
        % 如果当前系统中任务的个数大于了系统的容量，这个任务就直接被卸载到上层节点去了
        if(isRandomOffload || (~(k < 0) && state>k))
%             disp(state);
            state = state - 1;
            % 任务排队的时间为无穷大
%                 arrWaitTime(iArr) = inf;
            % 任务的逗留时间为无穷大
%                 arrTotalSysTime(iArr) = inf;
%                 srvingState(iArr) = -1;
            leaveTimeLine(end + 1) = arrTimeline(iArr);
            offloadedSrvTime(end + 1) = iArrSrvTime;
            % 在边缘服务器上被卸载了,还要额外保存该任务从设备层卸载到边缘节点层的的无线传输时间
            if configInfo.type == 2
                wirelessTrDelayOffloaded(end + 1) = wirelessTrDelay(iArr);
            end
        % 否则，就在当前系统进行运算
        else
            % 当前任务的等待时间即为目标服务器当前的负载（目标服务器还需要工作多久才能为空闲）
            arrWaitTime(end + 1) = minVal;
            % 给目标服务器加上负载
            server(minIndex) = server(minIndex) + iArrSrvTime;
            % 当前任务所经历的传输时延
            trDelay = 0;
            if configInfo.type == 2
                trDelay = wirelessTrDelay(iArr);
            end
            if configInfo.type == 3
                trDelay = wirelessTrDelay(iArr) + wiredTrDelay(iArr);
            end
            % 当前任务总的完成时延为当 前任务的服务时间 + 当前任务等待服务的时间 + 当前任务的传输时延
            arrTotalSysTime(end + 1) = iArrSrvTime + arrWaitTime(end) + trDelay;
            % 保存服务状态，这个就跟时间线挂钩了（任务还需要多久才能完成，不包括传输时延）
            srvingState(end + 1) = iArrSrvTime + arrWaitTime(end); 
        end
        iArr = iArr + 1;
    end
    % 这个find函数就是找当前哪几个任务已经完成了
    if(~isempty(find(srvingState<tolerance & srvingState>-tolerance, 1)))
        % 找到几个，当前系统中的任务个数就减这么多个
        state = state - sum(srvingState<tolerance & srvingState>-tolerance);
    end
    % 下标++
    iState = iState + 1;
    % 记录下每一个时刻系统中任务的个数
    noSysVector(iState) = state;
    % 记录下当前时刻是否有任务需要处理
    check(iState) = ~isempty(find(srvingState<tolerance & srvingState>-tolerance, 1));

    % 记录下每一个时间系统队列的任务个数，只要减去服务器的数量就可以了
    if(state>m)
        noQueueVector(iState) = state - m;
    else
        noQueueVector(iState) = 0;
    end
    
    %更新时间线
    i = i + step;
    concurrence = isTaskArrived && ~(iArr > length(arrTimeline)) && (arrTimeline(iArr) == arrTimeline(iArr - 1));
    % 处理并发情况，即任务同时到达的情况
    if concurrence
        i = i - step;
    end
end
if configInfo.type == 1
    result.leaveTimeLine = leaveTimeLine;
    result.offloadedSrvTime = offloadedSrvTime;
    result.arrTotalSysTime = arrTotalSysTime;
elseif configInfo.type == 2
    result.leaveTimeLine = leaveTimeLine;
    result.offloadedSrvTime = offloadedSrvTime;
    result.arrTotalSysTime = arrTotalSysTime;
    result.wirelessTrDelayOffloaded = wirelessTrDelayOffloaded;
else % type = 3
    result.arrTotalSysTime = arrTotalSysTime;
end

% disp('Simulation Ended.....');
% % % % % Simulation Ends

% plot(arrSrvTime,'--r');hold on;plot(arrTimes);hold off;


% figure;stairs(timeLine,noSysVector);
% title(['m = ' num2str(m) ' and k = ' num2str(k)]);
% xlabel('t - time axis');ylabel('N(t) - no. Packets in system');

% % % % % Time Averages
% avgExpNoSystem = trapz(timeLine,noSysVector)/timeLine(end);
% avgExpNoQueue = trapz(timeLine,noQueueVector)/timeLine(end);
% avgExpWaitTime = mean(arrWaitTime(arrWaitTime<inf));
% avgExpSysTime = mean(arrTotalSysTime(arrTotalSysTime<inf));


% % % % % Statistical Averages

% M/M/m/k system
% if configInfo.type == 2
%     rho = 1.0407 * m;
%     k = 3;
%     p0 = 1./(sum((rho.^(0:(m-1)))./factorial(0:(m-1)))+((rho^m/factorial(m))*((1-((rho/m)^(k-m+1)))/(1-(rho/m)))));
%     pk = (rho^k)*p0/(factorial(m)*(m^(k-m)));
%     disp(['pk is ', num2str(pk)]);
%     disp(['p0 is ', num2str(p0)]);
%     avgThryNoQueue = (rho^(m+1)*p0/factorial(m-1))*((1-(rho/m)^(k-m+1)-((1-rho/m)*(k-m+1)*((rho/m)^(k-m))))/(m-rho)^2);
%     avgThryNoSystem = avgThryNoQueue+rho;
%     lambda0 = lambda*(1-pk);
%     avgThryWaitTime = avgThryNoQueue/lambda0;
%     avgThrySysTime = avgThryNoSystem/lambda0;
end

% M/M/1/inf system uncomment the vaules below if used for mm1inf
% avgThryNoSystem = rho/(1-rho);
% avgThryNoQueue = avgThryNoSystem-rho;
% avgThryWaitTime = avgThryNoQueue/lambda;
% avgThrySysTime = avgThryNoSystem/lambda;

% Result = [avgExpNoSystem, avgExpNoQueue, avgExpSysTime, avgExpWaitTime;...
%           avgThryNoSystem,avgThryNoQueue, avgThrySysTime, avgThryWaitTime];  
% end

