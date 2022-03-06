% wireless_gains：%各个设备与边缘节点的无线信道的信道增益
% c_Edge：边缘服务器的个数
% deviceNum：设备个数
function [xmin] = getStrategy()
    global systemConfig;
    global bestOffloadNumResult;
    fitfun = @fitnessfun;
    deviceNum = systemConfig.deviceNum;
    dim = deviceNum + 1; % 维度，设备个数加上一个边缘节点的个数
    edgeNum = systemConfig.edgeNum; %边缘服务器个数
    T= 700; %迭代次数
    % 边缘节点排队系统容量的最小值 应当大于或等于 边缘服务器的个数，所以将搜索范围的最小值作为边缘服务器的个数
    Lb=[ones(1, deviceNum) edgeNum];
    Ub=[ones(1, deviceNum)*20 100];
    N=10; %种群大小
    [xmin,fmin,CNVG, FR, FRBest, CNVG_Subtract_STD]=HBA(fitfun,dim,Lb,Ub,T,N);
    
%     figure,
%     semilogy(CNVG,'r')
% %     semilogy(CNVG_Subtract_STD,'r') %要减去标准差的图
%     xlim([0 T]);
%     title('Convergence curve')
%     xlabel('Iteration');
%     ylabel('Best fitness obtained so far');
%     legend('HBA')

    bestOffloadNumResult.bestCapacity = xmin;
    bestOffloadNumResult.wireless_gains = systemConfig.wireless.wireless_gains;
    bestOffloadNumResult.finishTime = FRBest.finishTime;
    bestOffloadNumResult.FRBest = FRBest;
    display(['The best location= ', num2str(xmin)]);
%     display(['The best fitness score = ', num2str(fmin)]);
    display(['The best fitness score = ', num2str(FRBest.finishTime)]);
end

