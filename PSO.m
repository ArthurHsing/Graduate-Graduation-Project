function [fitnessBest, best_pos, Convergence_curve, FRBest] = PSO(N,T,Lb,Ub,dim,fobj,w,c1,c2,vlimit)
    Sol = initialization(N, dim, Ub, Lb);%初始种群的位置
    v = rand(N, dim);                  % 初始种群的速度
    Fitness = ones(N, 1).* Inf;               % 每个个体的历史最佳适应度
    fitnessBest = Inf;                      % 种群历史最佳适应度
    %% 群体更新
    iter = 1;
    Convergence_curve = zeros(1, T);          % 记录器
    for i = 1:N
        [fitnessTemp, fitnessRecord] = fobj(Sol(i,:));
        Fitness(i)= fitnessTemp;
        FR(i) = fitnessRecord;
    end
    
    % Find the current best_pos
    [fmin,I]=min(Fitness);
    best_pos=Sol(I,:); % 种群的历史最佳位置
    FRBest = FR(I);
    S=Sol; %拷贝一份用于位置更新操作
    
    while iter <= T
        for i = 1:N      
            % 边界位置处理
            FU=S(i,:)>Ub;
            FL=S(i,:)<Lb;
            S(i,:)=floor((S(i,:).*(~(FU+FL)))+Ub.*FU+Lb.*FL); %边界值判断，如果超过了边界值就取边界值，如果没有超过，就取原来的值
            
            [fnew, fitnessRecord] = fobj(S(i, :)) ; % 个体当前适应度   
            if fnew < Fitness(i) 
                Fitness(i) = fnew;     % 更新个体历史最佳适应度
                Sol(i,:) = S(i,:);   % 更新个体历史最佳位置
                FR(i) = fitnessRecord;
            end 
        end
        [fmin, index] = min(Fitness);
        if fmin < fitnessBest % 更新群体历史最佳适应度
            fitnessBest = fmin;
            best_pos = S(index, :);
            FRBest = FR(index);
        end
        v = v * w + c1 * rand * (Sol - S) + c2 * rand * (repmat(best_pos, N, 1) - S);% 速度更新
        % 边界速度处理
        v(v > vlimit(2)) = vlimit(2);
        v(v < vlimit(1)) = vlimit(1);
        S = S + v;% 位置更新
        
        Convergence_curve(iter) = fitnessBest;%最大值记录
        iter = iter+1;
    end
    % figure(1);plot(record);title('收敛过程')
end

% This function randomly initializes the position of agents in the search space.
function [X]=initialization(N,dim,up,down)

    if size(up,1)==1
        X=rand(N,dim).*(up-down)+down;
    end
    if size(up,1)>1
        for i=1:dim
            high=up(i);low=down(i);
            X(:,i)=rand(1,N).*(high-low)+low;
        end
    end
end
