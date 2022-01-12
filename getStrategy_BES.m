function [] = getStategy_BES()
    global systemConfig;
    global bestOffloadNumResult_BES;
    deviceNum = systemConfig.deviceNum;
    edgeNum = systemConfig.edgeNum; %边缘服务器个数
    fun = @fitnessfun;
    nPop = 10;
    MaxIt = 1000;
    dim = deviceNum + 1;
    low = [ones(1, deviceNum) edgeNum];
    high =[ones(1, deviceNum)*50 100];
    
    [value,fun_hist]=BES(nPop,MaxIt,low,high,dim,fun);
    bestOffloadNumResult_BES.FRBest = value
    plot(fun_hist,'-','Linewidth',1.5)
    xlabel('Iteration')
    ylabel('fitness')
    legend('BES')
end

