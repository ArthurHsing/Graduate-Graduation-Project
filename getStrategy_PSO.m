function [outputArg1,outputArg2] = getStrategy_PSO()
    global systemConfig;
    global bestOffloadNumResult_PSO;
    N = 10;                         % 初始种群个数
    deviceNum = systemConfig.deviceNum;
    dim = deviceNum + 1; % 维度，设备个数加上一个边缘节点的个数
    edgeNum = systemConfig.edgeNum; %边缘服务器个数
    T= 1000; %迭代次数
    Lb=[ones(1, deviceNum) edgeNum];
    Ub=[ones(1, deviceNum)*50 100];
    vlimit = [-5, 5];               % 设置速度限制
    w = 0.8;                        % 惯性权重
    c1 = 0.5;                       % 自我学习因子
    c2 = 0.5;                       % 群体学习因子 
    fitfun = @fitnessfun;
    [Best_score,Best_pos, cg_curve, FRBest] = PSO(N,T,Lb,Ub,dim,fitfun,w,c1,c2,vlimit);
    bestOffloadNumResult_PSO.FRBest = FRBest;
    
    figure,
    semilogy(cg_curve,'r')
    %     semilogy(CNVG_Subtract_STD,'r') %要减去标准差的图
    xlim([0 T]);
    title('Convergence curve')
    xlabel('Iteration');
    ylabel('Best fitness obtained so far');
    legend('PSO');
    
    display(['The best solution obtained by PSO is : ', num2str(Best_pos)]);
    display(['The best optimal value of the objective funciton found by PSO is : ', num2str(Best_score)]);
end
