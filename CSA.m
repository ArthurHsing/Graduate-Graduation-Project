function [fmin0,gPosition,cg_curve, FRBest]=CSA(searchAgents,iteMax,lb,ub,dim,fobj)

%%%%* 1
if size(ub,2)==1
    ub=ones(1,dim)*ub;
    lb=ones(1,dim)*lb;
end
 
%% Convergence curve
cg_curve=zeros(1,iteMax);

%% Initial population

chameleonPositions=floor(initialization(searchAgents,dim,ub,lb));% Generation of initial solutions 

%% Evaluate the fitness of the initial population

fit=zeros(searchAgents,1);


for i=1:searchAgents
    [tempFitness, fitnessRecord] = fobj(chameleonPositions(i,:));
     fit(i,1)=tempFitness;
     FR(i) = fitnessRecord;
end

%% Initalize the parameters of CSA
fitness=fit; % Initial fitness of the random positions
FRPersonalBestRecord = FR;

[fmin0,index]=min(fit);

chameleonBestPosition = chameleonPositions; % Best position initialization
gPosition = chameleonPositions(index,:); % initial global position
FRBest = FR(index);

v=0.1*chameleonBestPosition;% initial velocity
 
v0=0.0*v;

%% Start CSA 
% Main parameters of CSA
rho=1.0;
p1=2.0;  
p2=2.0;  
c1=2.0; 
c2=1.80;  
gamma=2.0; 
alpha = 4.0;  
beta=3.0; 
 

 %% Start CSA
for t=1:iteMax
a = 2590*(1-exp(-log(t))); 
omega=(1-(t/iteMax))^(rho*sqrt(t/iteMax)) ; 
p1 = 2* exp(-2*(t/iteMax)^2);  % 
p2 = 2/(1+exp((-t+iteMax/2)/100)) ;
        
mu= gamma*exp(-(alpha*t/iteMax)^beta) ;

ch=ceil(searchAgents*rand(1,searchAgents));
%% Update the position of CSA (Exploration)
for i=1:searchAgents  
             if rand>=0.1
                  chameleonPositions(i,:)= floor(chameleonPositions(i,:)+ p1*(chameleonBestPosition(ch(i),:)-chameleonPositions(i,:))*rand()+... 
                     + p2*(gPosition -chameleonPositions(i,:))*rand());
             else 
                 for j=1:dim
                   chameleonPositions(i,j)=   floor(gPosition(j)+mu*((ub(j)-lb(j))*rand+lb(j))*sign(rand-0.50)) ;
                 end 
              end   
end       
 
 %%  % Chameleon velocity updates and find a food source
     for i=1:searchAgents
               
        v(i,:)= omega*v(i,:)+ p1*(chameleonBestPosition(i,:)-chameleonPositions(i,:))*rand +.... 
               + p2*(gPosition-chameleonPositions(i,:))*rand;        

         chameleonPositions(i,:)=floor(chameleonPositions(i,:)+(v(i,:).^2 - v0(i,:).^2)/(2*a));
     end
    
  v0=v;
  
 %% handling boundary violations
 for i=1:searchAgents
     if chameleonPositions(i,:)<lb
        chameleonPositions(i,:)=lb;
     elseif chameleonPositions(i,:)>ub
            chameleonPositions(i,:)=ub;
     end
 end
 
 %% Relocation of chameleon positions (Randomization) 
for i=1:searchAgents
    
    ub_=sign(chameleonPositions(i,:)-ub)>0;   
    lb_=sign(chameleonPositions(i,:)-lb)<0;
       
    chameleonPositions(i,:)=floor((chameleonPositions(i,:).*(~xor(lb_,ub_)))+ub.*ub_+lb.*lb_);  %%%%%*2
 
    [tempFitness, fitnessRecord] = fobj (chameleonPositions(i,:));
    fit(i,1) = tempFitness;
    FR(i) = fitnessRecord;
%   fit(i,1)=fobj (chameleonPositions(i,:)) ;
      
      if fit(i)<fitness(i)
                 chameleonBestPosition(i,:) = chameleonPositions(i,:); % Update the best positions  
                 fitness(i)=fit(i); % Update the fitness
                 FRPersonalBestRecord(i) = FR(i);
      end
 end


%% Evaluate the new positions

[fmin,index]=min(fitness); % finding out the best positions  


% Updating gPosition and best fitness
if fmin < fmin0
    gPosition = chameleonBestPosition(index,:); % Update the global best positions
    fmin0 = fmin;
    FRBest = FRPersonalBestRecord(index);
end

%% Visualize the results

   cg_curve(t)=fmin0; % Best found value until iteration t
end
 
ngPosition=find(fitness== min(fitness)); 
g_best=chameleonBestPosition(ngPosition(1),:);  % Solutin of the problem
fmin0 =fobj(g_best);

end

function pos=initialization(searchAgents,dim,u,l)

% This function initialize the first population of search agents
Boundary_no= size(u,2); % numnber of boundaries

% If the boundaries of all variables are equal and user enter a signle
% number for both u and l
if Boundary_no==1
    u_new=ones(1,dim)*u;
    l_new=ones(1,dim)*l;
else
     u_new=u;
     l_new=l;   
end

% If each variable has a different l and u
    for i=1:dim
        u_i=u_new(i);
        l_i=l_new(i);
        pos(:,i)=rand(searchAgents,1).*(u_i-l_i)+l_i;
    end
end