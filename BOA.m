%_____________________________________________________________________________________________ %
%  Butterfly Optimization Algorithm (BOA) source codes demo V1.0                               %
%                                                                                              %
%  Author and programmer: Sankalap Arora                                                       %
%                                                                                              %
%         e-Mail: sankalap.arora@gmail.com                                                     %
%                                                                                              %
%  Main paper: Sankalap Arora, Satvir Singh                                                    %
%              Butterfly optimization algorithm: a novel approach for global optimization	   %
%              Soft Computing, in press,                                                       %
%              DOI: https://doi.org/10.1007/s00500-018-3102-4                                  %
%___________________________________________________________________________________________   %
%
function [fmin,best_pos,Convergence_curve, FRBest]=BOA(n,N_iter,Lb,Ub,dim,fobj)

    % n is the population size
    % N_iter represnets total number of iterations
    p=0.8;                       % probabibility switch
    power_exponent=0.1;
    sensory_modality=0.01;

    %Initialize the positions of search agents
    Sol=floor(initialization(n,dim,Ub,Lb));

    for i=1:n
        [fitnessTemp, fitnessRecord] = fobj(Sol(i,:));
        Fitness(i)=fobj(Sol(i,:));
        FR(i) = fitnessRecord;
    end
    
    % Find the current best_pos
    [fmin,I]=min(Fitness);
    best_pos=Sol(I,:);
    FRBest = FR(I);
    S=Sol; 

    % Start the iterations -- Butterfly Optimization Algorithm 
    for t=1:N_iter

            for i=1:n % Loop over all butterflies/solutions

              %Calculate fragrance of each butterfly which is correlated with objective function
            if isnan(S(i,:))
                disp('111');
            end
              Fnew=fobj(S(i,:)); %这个实际上不是最新的，是上一次迭代的的，下面的操作在更新这个S(i, :)
              if isnan(Fnew)
                  dips('111');
              end
              FP=(sensory_modality*(Fnew^power_exponent));   

              %Global or local search
              if rand<p    
                dis = rand * rand * best_pos - Sol(i,:);        %Eq. (2) in paper
                S(i,:)=Sol(i,:)+dis*FP;
               else
                  % Find random butterflies in the neighbourhood
                  epsilon=rand;
                  JK=randperm(n);
                  dis=epsilon*epsilon*Sol(JK(1),:)-Sol(JK(2),:);
                  S(i,:)=Sol(i,:)+dis*FP;                         %Eq. (3) in paper
              end
                if isnan(S(i,:))
                    disp('111');
                end              
                FU=S(i,:)>Ub;
                FL=S(i,:)<Lb;
                % Check if the simple limits/bounds are OK
                S(i,:)=floor((S(i,:).*(~(FU+FL)))+Ub.*FU+Lb.*FL); %边界值判断，如果超过了边界值就取边界值，如果没有超过，就取原来的值
%                 S(i,:)=(S(i,:).*(~(FU+FL)))+Ub.*FU+Lb.*FL; %边界值判断，如果超过了边界值就取边界值，如果没有超过，就取原来的值
%                 S(i,:)=simplebounds(S(i,:),Lb,Ub);
                
                % Evaluate new solutions
%                 Fnew=fobj(S(i,:));  %Fnew represents new fitness values
                if isnan(S(i,:))
                    disp('111');
                end
                [Fnew, fitnessRecord]=fobj(S(i,:));  %Fnew represents new fitness values
                % If fitness improves (better solutions found), update then
                if (Fnew<=Fitness(i))
                    Sol(i,:)=S(i,:);
                    Fitness(i)=Fnew;
                    FR(i) = fitnessRecord;
                end

               % Update the current global best_pos
               if Fnew<=fmin
                    best_pos=S(i,:);
                    fmin=Fnew;
                    FRBest = fitnessRecord;
               end
             end

             Convergence_curve(t,1)=fmin;

             %Update sensory_modality
              sensory_modality=sensory_modality_NEW(sensory_modality, N_iter);
    end
end
% Boundary constraints
function s=simplebounds(s,Lb,Ub)
  % Apply the lower bound
  ns_tmp=s;
  I=ns_tmp<Lb;
  ns_tmp(I)=Lb;
  
  % Apply the upper bounds 
  J=ns_tmp>Ub;
  ns_tmp(J)=Ub;
  % Update this new move 
  s=ns_tmp;
end
  
function y=sensory_modality_NEW(x,Ngen)
    y=x+(0.025/(x*Ngen));
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
