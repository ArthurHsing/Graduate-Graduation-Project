function [bestPosition] = getStrategy_CSA()
    global systemConfig;
    global bestOffloadNumResult_CSA;
    %% % Prepare the problem
    deviceNum = systemConfig.deviceNum;
    edgeNum = systemConfig.edgeNum; %边缘服务器个数
    dim = deviceNum + 1;
    ub = [ones(1, deviceNum)*50 100];
    lb = [ones(1, deviceNum) edgeNum];
    fobj = @fitnessfun;

    %% % CSA parameters 
    noP = 10;
    maxIter = 1000;

    [bestFitness, bestPosition, CSAConvCurve, FRBest] =CSA(noP,maxIter,lb,ub,dim,fobj);
    bestOffloadNumResult_CSA.FRBest = FRBest;
%     semilogy(CSAConvCurve,'Color','r')
%     title('Convergence curve')
%     xlabel('Iteration');
%     ylabel('Best score obtained so far');
% 
%     axis tight
%     grid off
%     box on
%     legend('CSA')

    display(['The best solution obtained by CSA is : ', num2str(bestPosition)]);
    display(['The best optimal value of the objective funciton found by CSA is : ', num2str(FRBest.finishTime)]);

end

