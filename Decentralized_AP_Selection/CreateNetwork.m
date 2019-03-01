% In this file we generate a network of links (between the AP and a node).

function [AP,STA,NodeMatrix,shadowingmatrix]=CreateNetwork(N_APs,N_STAs,L,CWmin,SLOT,cluster,B)

MaxChannels = 8;
EB=(CWmin-1)*SLOT/2;

MaxX=80;
MaxY=80;

disp('Density of APs');
disp(N_APs/(MaxX*MaxY));


for j=1:N_APs
    
    AP(j).channel=ceil(MaxChannels*rand());    
    AP(j).x = MaxX*rand();
    AP(j).y = MaxY*rand();    
    AP(j).stas = 0;
    AP(j).EB=EB;
    AP(j).L=L;
    AP(j).CCA=-82;
    AP(j).CW=CWmin;
    AP(j).airtime = 0;
    
end

switch N_APs
    case 2
        AP(1).x=MaxX/3;
        AP(1).y=MaxY/2;
        AP(2).x=(MaxX/3)*2;
        AP(2).y=MaxY/2;
    case 3
        AP(1).x=MaxX/4;
        AP(1).y=MaxY/2;
        AP(2).x=(MaxX*2/4);
        AP(2).y=(MaxX/2);
        AP(3).x=MaxX*3/4;
        AP(3).y=(MaxY/2);
    case 4
        AP(1).x=MaxX/3;
        AP(1).y=MaxY/3;
        AP(2).x=(MaxX/3)*2;
        AP(2).y=(MaxX/3)*2;
        AP(3).x=MaxX/3;
        AP(3).y=(MaxY/3)*2;
        AP(4).x=(MaxX/3)*2;
        AP(4).y=MaxY/3;
    case 16
        for i=1:4            
            for j=1:4                
                AP(j+(4*(i-1))).x=(MaxX/5)*mod(i-1,4)+(MaxX/5);
                AP(j+(4*(i-1))).y=(MaxY/5)*mod(j-1,4)+(MaxY/5);
            end            
        end
    
end



for i=1:N_STAs
    if(cluster==0)
        STA(i).x = rand()*MaxX;
        STA(i).y = rand()*MaxY;
    else
       if(mod(i-1,10)==0)
           centerx = (MaxX-5 - 5)*rand()+5;
           centery = (MaxY-5 - 5)*rand()+5;
       end
     

       STA(i).x = ((centerx+5) - (centerx-5))*rand() + (centerx-5);
       STA(i).y = ((centery+5) - (centery-5))*rand() + (centery-5);
           
    end
    STA(i).L=L;
    STA(i).CCA=-82;
    STA(i).CW=CWmin;


    STA(i).B = B;  
    STA(i).APs = -inf.*ones(1,N_APs);
    STA(i).d_APs = -inf.*ones(1,N_APs);
    STA(i).nAPs = 0;
    STA(i).Be = 0;
    STA(i).satisfaction = 0;
    STA(i).accB=0;
    STA(i).associated_AP = 0;
    STA(i).ass=zeros(1,N_APs);
    STA(i).APs_range = 0;
    STA(i).APs_reward = zeros(1,N_APs);
    STA(i).APs_rew=zeros(N_APs,50);
    STA(i).APs_rewIt=zeros(1,N_APs);
    STA(i).Epsilon = [0 , 0.75 , 1; 0 , 0 , 0]; % First row is Eps values, second is how many times they are used
    STA(i).sticky = [0 , 4 , 0];    % First one is the sticky counter, second is the limit for some experiments, third is the global sticky counter
    


end



% Interference at every destination

PTdBm = 20;
shawdowing = 5;

shadowingmatrix = shawdowing*randn(N_APs+N_STAs);
shadowingmatrix = triu(shadowingmatrix)+triu(shadowingmatrix)';


PL0TMB=54.12;
gammaTMB=2.06067;
kTMB = 5.25;
WTMB = 0.1467;
NodeMatrix=zeros(N_APs+N_STAs);
for i=1:N_APs+N_STAs
    for j=1:N_APs+N_STAs
        if(i<=N_APs && j<=N_APs)
            d=sqrt((AP(i).x-AP(j).x)^2+(AP(i).y-AP(j).y)^2);            
            PL = PL0TMB + 10 * gammaTMB * log10(d) + kTMB * WTMB * d + shadowingmatrix(i,j);
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i<=N_APs && j>N_APs)
            d=sqrt((AP(i).x-STA(j-N_APs).x)^2+(AP(i).y-STA(j-N_APs).y)^2);
            STA(j-N_APs).d_APs(i)=d;            
            PL = PL0TMB + 10 * gammaTMB * log10(d) + kTMB * WTMB * d + shadowingmatrix(i,j);
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i>N_APs && j<=N_APs)
            d=sqrt((STA(i-N_APs).x-AP(j).x)^2+(STA(i-N_APs).y-AP(j).y)^2);           
            PL = PL0TMB + 10 * gammaTMB * log10(d) + kTMB * WTMB * d + shadowingmatrix(i,j);
            NodeMatrix(i,j)=PTdBm-PL;
        end
        if(i>N_APs && j>N_APs)
            d=sqrt((STA(i-N_APs).x-STA(j-N_APs).x)^2+(STA(i-N_APs).y-STA(j-N_APs).y)^2);           
            PL = PL0TMB + 10 * gammaTMB * log10(d) + kTMB * WTMB * d + shadowingmatrix(i,j);
            NodeMatrix(i,j)=PTdBm-PL;
        end
    end
end

 NodeMatrix(NodeMatrix==inf)=0;
 NodeMatrix(isnan(NodeMatrix))=0;

end
