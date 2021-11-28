clear all;close all;clc;

% % % % % Initializations
srvingState = [];
arrTotalSysTime = [];
arrWaitTime = [];
leaveTimeLine = [];%离开时间点
noQueueVector = [];%记录系统中正在排队的任务的数组
noSysVector = [];%记录系统中总的任务的数组
m = 1;%服务器数量
k = 100;%系统容量
mu = 1*m; %服务率
lambda = 0.9;%任务到达率
noArr = 1000; %一共有多少个任务
d = 1; %横坐标步长指数
iArr = 1; %下标，现在在处理第几个任务
iState = 0; %下标，理解为第几个时间的下标
state = 0; %当前系统中有多少个任务
firstArrived = 0;
j=1;

% % % % % Arrival Times
step = 10^-d; tolerance = 10^-(d+1);rho = lambda/mu;
arrTimes = round((exprnd((1/lambda),1,noArr)+(10^-d)),d);%noArr个任务的到达时间间隔
arrTimeline = cumsum(arrTimes);%加起来就是noArr个任务分别的到达时间线
timeLine = 0:step:ceil(arrTimeline(end));%离散的横轴，每个横轴的间距是step，横轴的长度仍然是刚刚生成的任务时间线的长度
server(1:m) = 0;check = [];

disp('Simulation Running............');
% % % % % Simulation Starts

% i可以理解为是时间线，它以步长在增加
for i = 0:step:ceil(arrTimeline(end))
    iArr
    
    srvingState = srvingState - step;
    %server记录的是各服务器距离空闲还剩多少时间，因为每一次循环就相当于经过了step这么长的时间，所以要减去step
    server = server - step;
    
    %如果减完了发现距离空闲所剩的时间为负了，那说明该服务器上没有待处理的任务了，也就是服务器已经空闲了
    for iServer=1:m
        if(server(iServer)<0)
            server(iServer) = 0;
        end
    end
    
    %记录下每一时刻服务器的状态
    monitor(iState+1,:) = server;
    
    %这是边界处理，在循环的末尾估计会用到这个
    if(iArr>length(arrTimeline))
        iArr = length(arrTimeline);
    end
    
    % i可以理解为是时间线，它以步长step在增加
    % 这里可以理解为当第iArr个任务已经到了，估计是因为浮点数不好做相等比较，所以这里用了一个tolerance误差来表示
    % 之前在JS中我也用过类似的表示方法
    if(abs(i-arrTimeline(iArr))<tolerance)
        % 任务来了，系统中任务的个数就需要+1了
        state = state + 1;
        % 拿到当前较为空闲的服务器
        [minVal, minIndex] = min(server);
        % 如果当前系统中任务的个数大于了系统的容量，这个任务就直接被丢弃掉了
        if(state>k)
            state = state - 1;
            % 任务排队的时间为无穷大
            arrWaitTime(iArr) = inf;
            % 任务的逗留时间为无穷大
            arrTotalSysTime(iArr) = inf;
            srvingState(iArr) = -1;
        % 否则
        else
            % 给当前任务安排一个服从指数分布的服务时间
            iArrSrvTime = round((exprnd((1/mu))+(10^-d)),d);
            arrSrvTime(iArr) = iArrSrvTime; %第iArr个任务的服务时间
            % 当前任务的等待时间即为目标服务器当前的负载（目标服务器还需要工作多久才能为空闲）
            arrWaitTime(iArr) = minVal;
            % 给目标服务器加上负载
            server(minIndex) = server(minIndex) + iArrSrvTime;
            % 当前任务总的逗留时间为当前任务的服务时间+当前任务等待服务的时间
            arrTotalSysTime(iArr) = iArrSrvTime + arrWaitTime(iArr);
            % 保存服务状态，这个就跟时间线挂钩了
            srvingState(iArr) = arrTotalSysTime(iArr); 
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
    
end
disp('Simulation Ended.....');
% % % % % Simulation Ends

% plot(arrSrvTime,'--r');hold on;plot(arrTimes);hold off;
leaveTimeLine = arrTimeline + arrTotalSysTime;

figure;stairs(timeLine,noSysVector);
title(['m = ' num2str(m) ' and k = ' num2str(k)]);
xlabel('t - time axis');ylabel('N(t) - no. Packets in system');

% % % % % Time Averages
avgExpNoSystem = trapz(timeLine,noSysVector)/timeLine(end);
avgExpNoQueue = trapz(timeLine,noQueueVector)/timeLine(end);
avgExpWaitTime = mean(arrWaitTime(arrWaitTime<inf));
avgExpSysTime = mean(arrTotalSysTime(arrTotalSysTime<inf));


% % % % % Statistical Averages

% M/M/m/k system
p0 = 1./(sum((rho.^(0:(m-1)))./factorial(0:(m-1)))+((rho^m/factorial(m))*((1-((rho/m)^(k-m+1)))/(1-(rho/m)))));
pk = (rho^k)*p0/(factorial(m)*(m^(k-m)));
avgThryNoQueue = (rho^(m+1)*p0/factorial(m-1))*((1-(rho/m)^(k-m+1)-((1-rho/m)*(k-m+1)*((rho/m)^(k-m))))/(m-rho)^2);
avgThryNoSystem = avgThryNoQueue+rho;
lambda0 = lambda*(1-pk);
avgThryWaitTime = avgThryNoQueue/lambda0;
avgThrySysTime = avgThryNoSystem/lambda0;

% M/M/1/inf system uncomment the vaules below if used for mm1inf
% avgThryNoSystem = rho/(1-rho);
% avgThryNoQueue = avgThryNoSystem-rho;
% avgThryWaitTime = avgThryNoQueue/lambda;
% avgThrySysTime = avgThryNoSystem/lambda;

Result = [avgExpNoSystem, avgExpNoQueue, avgExpSysTime, avgExpWaitTime;...
          avgThryNoSystem,avgThryNoQueue, avgThrySysTime, avgThryWaitTime];  
      
      
