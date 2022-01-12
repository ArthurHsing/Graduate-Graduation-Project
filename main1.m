%% Chameleon Swarm Algorithm (CSA) source codes version 1.0______
   
clear 
close all
clc
%% % Prepare the problem
dim = 2;
ub = 50 * ones(1, 2);
lb = -50 * ones(1, 2);
fobj = @Objfun;

%% % CSA parameters 
noP = 30;
maxIter = 1000;
 

             [bestFitness, bestPosition, CSAConvCurve] =Chameleon(noP,maxIter,lb,ub,dim,fobj);

              disp(['===> The optimal fitness value found by Standard Chameleon is ', num2str(bestFitness, 15)]);
