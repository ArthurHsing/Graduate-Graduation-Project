%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Honey Badger Algorithm source code 
%  paper:
%     Hashim, Fatma A., Essam H. Houssein, Kashif Hussain, Mai S. %     Mabrouk, Walid Al-Atabany. 
%     "Honey Badger Algorithm: New Metaheuristic Algorithm for %  %     Solving Optimization Problems." 
%     Mathematics and Computers in Simulation, 2021.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Xprey是全局最优解得位置，Food_Score是全局最优解，CNVG是每次迭代的最优解
function [Xprey, Food_Score,CNVG, historyXpreys, FR] = HBA(objfunc, dim,lb,ub,tmax,N,systemConfig)
beta       = 2;     % the ability of HB to get the food  Eq.(4)
C       = 1;     %constant in Eq. (3)
vec_flag=[1,-1];
%initialization
X=initialization(N,dim,ub,lb);
% disp(X);
%Evaluation
[fitness, FR]= fun_calcobjfunc(objfunc, X, systemConfig);
% disp(fitness);
[GYbest, gbest] = min(fitness);
Xprey = X(gbest,:);
historyXpreys(1, :) = Xprey;
CNVG = zeros(1, tmax);
for t = 1:tmax
    alpha=C*exp(-t/tmax);   %density factor in Eq. (3)
    I=Intensity(N,Xprey,X); %intensity in Eq. (2)
    Xnew = zeros(N, dim);
    for i=1:N
        r =rand(); %一旦r确定了，当前个体所有维度的更新都只能采用一种方法
        F=vec_flag(floor(2*rand()+1));
        for j=1:1:dim
            di=abs((Xprey(j)-X(i,j)));
            if r<.5
%             if t > tmax/2
                r3=rand;                r4=rand;                r5=rand;
                temp11 = Xprey(j);
                temp12 = F*beta*I(i)* Xprey(j);
                temp13 = F*r3*alpha*(di)*abs(cos(2*pi*r4)*(1-cos(2*pi*r5)));
                temp1 = temp11 + temp12 + temp13;
%                 fprintf('temp1 is %d\n',temp1);
                Xnew(i,j) = temp1;
%                 Xnew(i,j)=Xprey(j) +F*beta*I(i)* Xprey(j)+F*r3*alpha*(di)*abs(cos(2*pi*r4)*(1-cos(2*pi*r5)));
            else
                r7=rand;
                temp21 = Xprey(j);
                temp22 = F*r7*alpha*di;
                temp2 = temp21 + temp22;
%                 fprintf('temp2 is %d\n',temp2);
                Xnew(i,j)= temp2;
            end
        end
        FU=Xnew(i,:)>ub;
        FL=Xnew(i,:)<lb;
        Xnew(i,:)=floor((Xnew(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL); %边界值判断，如果超过了边界值就取边界值，如果没有超过，就取原来的值
        [tempFitness, tempFR] = fun_calcobjfunc(objfunc, Xnew(i,:), systemConfig); %当前个体的适应值
        if tempFitness<fitness(i) %fitness(i)是当前个体的历史最优值
            fitness(i)=tempFitness; %更新最优值
            FR(i) = tempFR;
            X(i,:)= Xnew(i,:); %更新最优位置
        end
    end
    FU=X>ub;
    FL=X<lb;
    X=floor((X.*(~(FU+FL)))+ub.*FU+lb.*FL); %这里又在进行边界值处理，感觉没有必要
    [Ybest,index] = min(fitness); %当前迭代所有个体的最优值和下标
    CNVG(t)=min(Ybest); %保存当前迭代的最优值，这个min就用得很魔性，Ybest就是一个数而已
    if Ybest<GYbest %用当前的最优值去更新全局的最优值
        GYbest=Ybest;
        Xprey = X(index,:);
    end
    historyXpreys(t + 1, :) = Xprey;
end
% disp(CNVG);
Food_Score = GYbest;
end

function [Y, FR] = fun_calcobjfunc(func, X, systemConfig)
N = size(X,1);
Y = zeros(1, N);
for i = 1:N
    [fitness, fitnessRecord] = func(X(i,:), systemConfig);
    Y(i) = fitness;
    FR(i) = fitnessRecord;
end
end
function I=Intensity(N,Xprey,X)
di = zeros(1, N);
S = zeros(1, N);
for i=1:N-1
    %norm的含义是求欧几里得范数
    di(i) =( norm((X(i,:)-Xprey+eps))).^2;
    S(i)=( norm((X(i,:)-X(i+1,:)+eps))).^2;
end
di(N)=( norm((X(N,:)-Xprey+eps))).^2;
S(N)=( norm((X(N,:)-X(1,:)+eps))).^2;
I = zeros(1, N);
for i=1:N
    r2=rand;
    if di(i)-0 < 1e-1
        I(i) = 0;
    else
        I(i)=r2*S(i)/(4*pi*di(i));
    end
end
end
function [X]=initialization(N,dim,up,down)
if size(up,2)==1
    X=floor(rand(N,dim).*(up-down)+down);
end
if size(up,2)>1
    for i=1:dim
        high=up(i);low=down(i);
        X(:,i)=floor(rand(N,1).*(high-low)+low);
    end
end
end
