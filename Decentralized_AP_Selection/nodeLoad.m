function [AP,STA] = nodeLoad(AP,STA,Bmax,NodeMatrix,it,SC,CWmin)

N_STAs=length(STA);
N_APs=length(AP);


% ------------ Load AP ---------------

for j=1:N_APs
    AP(j).airtime = 0;
end

for i=1:N_STAs
   if(STA(i).nAPs>0)
        airtime = RequiredAirtimeUser(STA(i).B,STA(i).L,NodeMatrix(i+N_APs,STA(i).associated_AP),CWmin);
        channel = AP(STA(i).associated_AP).channel;
        for j=1:N_APs
          if(STA(i).APs(j)>-inf && AP(j).channel == channel)     
            AP(j).airtime = AP(j).airtime + airtime;  
          end
        end
   end
end


% ------------ Received Bandwidth ---------------


for i = 1:N_STAs
    if(STA(i).associated_AP~=0)
        airtime = RequiredAirtimeUser(STA(i).B,STA(i).L,NodeMatrix(i+N_APs,STA(i).associated_AP),CWmin);
        if(STA(i).nAPs > 0)
            if(AP(STA(i).associated_AP).airtime <= 1)
                
                STA(i).Be = STA(i).B;
                STA(i).satisfaction = STA(i).satisfaction + 1;
                
                STA(i).sticky(1)=SC;    % This can reset
                STA(i).sticky(3)=STA(i).sticky(3)+1;    % This is global                
                STA(i).APs_reward(STA(i).associated_AP) = STA(i).APs_reward(STA(i).associated_AP) + 1;
                STA(i).APs_rewIt(STA(i).associated_AP)= STA(i).APs_rewIt(STA(i).associated_AP)+1;
              
            else
                STA(i).sticky(1)= STA(i).sticky(1) - 1;
                STA(i).Be = STA(i).B*(airtime / AP(STA(i).associated_AP).airtime)*airtime;
                STA(i).satisfaction = STA(i).satisfaction + 0;
                STA(i).APs_reward(STA(i).associated_AP) = STA(i).APs_reward(STA(i).associated_AP) + (((airtime /AP(STA(i).associated_AP).airtime)));    % Comment for binary rewards
                STA(i).APs_rewIt(STA(i).associated_AP)= STA(i).APs_rewIt(STA(i).associated_AP)+1;
               
            end
            STA(i).satisf(it)=STA(i).satisfaction;
            STA(i).accB(it)=STA(i).Be;
        else
            STA(i).Be = 0;            
        end
    else
        % Nothing
    end
end

