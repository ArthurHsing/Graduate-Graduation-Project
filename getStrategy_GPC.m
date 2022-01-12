function [] = getStrategy_GPC()
    global systemConfig;
    global bestOffloadNumResult_GPC;
    %% Problem Definition
    CostFunction=@fitnessfun;        % Cost Function
    deviceNum = systemConfig.deviceNum;
    
    edgeNum = systemConfig.edgeNum; %边缘服务器个数

    nVar=deviceNum + 1;                  % Number of Decision Variables

    VarSize=[1 nVar];         % Decision Variables Matrix Size

    VarMin= [ones(1, nVar - 1).*1 edgeNum];             % Decision Variables Lower Bound
    VarMax= [ones(1, nVar - 1)*20 100];             % Decision Variables Upper Bound

    %% Giza Pyramids Construction (GPC) Parameters

    MaxIteration=1000;   % Maximum Number of Iterations (Days of work)

    nPop=10;             % Number of workers

    G = 9.8;             % Gravity
    Tetha = 14;          % Angle of Ramp
    MuMin = 1;           % Minimum Friction 
    % MuMin = ones(1, nVar)*1;           % Minimum Friction 

    MuMax = 10;          % Maximum Friction
    % MuMax = [ones(1, nVar - 1)*10 20];          % Maximum Friction

    pSS= 0.5;            % Substitution Probability
    %CostFunction, VarSize, VarMin, VarMax, MaxIteration, nPop, G, Tetha, MuMin, MuMax, pSS
    [Best_score,Best_pos,cg_curve, FRBest]=GPC(CostFunction, VarSize, VarMin, VarMax, MaxIteration, nPop, G, Tetha, MuMin, MuMax, pSS);
    bestOffloadNumResult_GPC.FRBest = FRBest;
    
    semilogy(cg_curve,'Color','r')
    title('Convergence curve')
    xlabel('Iteration');
    ylabel('Best score obtained so far');

    axis tight
    grid off
    box on
    legend('GPC')

    display(['The best solution obtained by GPC is : ', num2str(Best_pos)]);
    display(['The best optimal value of the objective funciton found by GPC is : ', num2str(FRBest.finishTime)]);
end

