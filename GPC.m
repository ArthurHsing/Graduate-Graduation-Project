function [Best_score,Best_pos,cg_curve, FRBest] = GPC(...
    CostFunction, VarSize, VarMin, VarMax, MaxIteration, nPop, G, Tetha, MuMin, MuMax, pSS)
    %% Initialization
    % Empty Stones Structure
    stone.Position=[];
    stone.Cost=[];
    stone.FR = struct([]);

    % Initialize Population Array
    pop=repmat(stone,nPop,1);

    % Initialize Best Solution Ever Found
    best_worker.Cost=inf;

    % Create Initial Stones
    for i=1:nPop
       pop(i).Position=floor(unifrnd(VarMin,VarMax));
       [fitness, fitnessRecord] = CostFunction(pop(i).Position);
       pop(i).Cost = fitness;
       pop(i).FR = fitnessRecord;
       if pop(i).Cost<=best_worker.Cost
           best_worker=pop(i);          % as Pharaoh's special agent
       end
    end

    % Array to Hold Best Cost Values
    BestCost=zeros(MaxIteration,1);

    %% Giza Pyramids Construction (GPC) Algorithm Main Loop
    for it=1:MaxIteration
        newpop=repmat(stone,nPop,1);

        for i=1:nPop
            newpop(i).Cost = inf;

            V0= rand(1,1);                          % Initial Velocity                                      
            Mu= MuMin+(MuMax-MuMin)*rand(1,1);      % Friction

            d = (V0^2)/((2*G)*(sind(Tetha)+(Mu*cosd(Tetha))));                  % Stone Destination
            x = (V0^2)/((2*G)*(sind(Tetha)));                                   % Worker Movement
            epsilon=unifrnd(-((VarMax-VarMin)/2),((VarMax-VarMin)/2),VarSize);  % Epsilon
%             newsol.Position = (pop(i).Position+d).*(x*epsilon);                 % Position of Stone and Worker
          newsol.Position = floor((pop(i).Position+d)+(x*epsilon));                  % Note: In some cases or some problems use this instead of the previous line to get better results

            newsol.Position=max(newsol.Position,VarMin);
            newsol.Position=min(newsol.Position,VarMax);

            % Substitution
            z=zeros(size(pop(i).Position));
            k0=randi([1 numel(pop(i).Position)]);
            for k=1:numel(pop(i).Position)
                if k==k0 || rand<=pSS
                    z(k)=newsol.Position(k);
                else
                    z(k)=pop(i).Position(k);
                end
            end

            newsol.Position=z;
            [fitness, fitnessRecord] = CostFunction(pop(i).Position);            
            newsol.Cost=fitness;
            newsol.FR = fitnessRecord;            

            if newsol.Cost <= newpop(i).Cost
               newpop(i) = newsol;
               if newpop(i).Cost<=best_worker.Cost
                   best_worker=newpop(i);
               end
            end

        end

        % Merge
        pop=[pop 
             newpop];  %#ok

        % Sort
        [~, SortOrder]=sort([pop.Cost]);
        pop=pop(SortOrder);

        % Truncate
        pop=pop(1:nPop);

        % Store Best Cost Ever Found
        BestCost(it)=pop(1).Cost;

        % Show Iteration Information
%         disp(['It:' num2str(it) ', Cost => ' num2str(BestCost(it))]);
    end
    Best_score = BestCost(it);
    Best_pos = pop(1).Position;
    cg_curve = BestCost;
    FRBest = pop(1).FR;
end

