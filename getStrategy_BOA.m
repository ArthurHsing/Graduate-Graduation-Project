function [] = getStrategy_BOA()
    global systemConfig;
    global bestOffloadNumResult_BOA;
    N=10; % 种群大小
%     N = 30;
%     fobj = @F1;
    fobj = @fitnessfun;
    deviceNum = systemConfig.deviceNum;
    dim = deviceNum + 1; % 维度，设备个数加上一个边缘节点的个数
%     dim = 30;
    edgeNum = systemConfig.edgeNum; %边缘服务器个数
    T= 1000; %迭代次数
%     T = 500;
    Lb=[ones(1, deviceNum) edgeNum];
%     Lb = -100;
    Ub=[ones(1, deviceNum)*50 100];
%     Ub = 100;
    [Best_score,Best_pos,cg_curve, FRBest]=BOA(N,T,Lb,Ub,dim,fobj);
    bestOffloadNumResult_BOA.FRBest = FRBest;
    semilogy(cg_curve,'Color','r')
    title('Convergence curve')
    xlabel('Iteration');
    ylabel('Best score obtained so far');

    axis tight
    grid off
    box on
    legend('BOA')

    display(['The best solution obtained by BOA is : ', num2str(Best_pos)]);
    display(['The best optimal value of the objective funciton found by BOA is : ', num2str(FRBest.finishTime)]);
end

function o = F1(x)
o=sum(x.^2);
end
