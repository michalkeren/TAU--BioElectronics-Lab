function [S1, S2, R_S1, R_S2, s1_s2, s2_s1] = find_S1_S2(X,Threshold,padding,ECG,t,t_ecg,section)
% written by Michal Keren, 2020

    %% find locations of S1 or S2:
    locs=find_peaks_locations(X,padding,Threshold);
        
    %% split to S1 S2:
    S1=zeros(length(X),1);
    S2=zeros(length(X),1);

    for i=2:(length(locs)-1)
        j=locs(i);
        prev= locs(i)-locs(i-1);
        next=locs(i+1)-locs(i);
        if(next>prev) %S2
            S2(j)=1;
        else
            S1(j)=1;
        end
    end
    
    if(S2(locs(2))==1)
       S1(locs(1))=1;
    else
        S2(locs(1))=1;
    end
    if(S2(locs(length(locs)-1))==1)
       S1(locs(length(locs)))=1;
    else
        S2(locs(length(locs)))=1;
    end
    
   
    %% calc time diffs :
    if section== "relaxed"
        Ns=1064;
        m_S1=S1(:);
        m_S1(1:Ns)=0;
        m_S2=S2(:);
        m_S2(1:Ns)=0;

        m_ECG=ECG(:);
        m_ECG(1:Ns)=0;

        S1_time=t(m_S1==1);
        S2_time=t(m_S2==1);
        S2_time=S2_time(2:length(S2_time));
        s1_s2= S2_time-S1_time;
        s2_s1= S1_time(2:end)- S2_time(1:end-1);
        R_locs=find_peaks_locations(m_ECG,50,0.5);
        R_times= t_ecg(R_locs);
        R_times= R_times(4:4+length(S1_time)-1);

        R_S1=S1_time- R_times;
        R_S2=S2_time- R_times;
    else
        %fix S1 S2
        for i=1:(length(locs)-1)
            j=locs(i);
            next=locs(i+1);
            if(S1(j)==1) 
                S2(next)=1;
                S1(next)=0;
            else
                S1(next)=1;
                S2(next)=0;
            end
        end
        
        % calc time diffs 
        S1_time=t(S1==1);
        S2_time=t(S2==1);
        R_locs=find_peaks_locations(ECG,50,0.5);
        R_times = t_ecg(R_locs).';
        R_times= R_times(3:end);

        s1_s2= S2_time-S1_time;
        s2_s1= S1_time(2:end)- S2_time(1:end-1);
       
        R_S1= S1_time(1:21)- R_times;
        R_S2=S2_time(1:21)- R_times;
    end
    %% plot
    S1_p=S1(:);
    S2_p=S2(:);
    S1_p(S1_p==0)=nan;
    S2_p(S2_p==0)=nan;
    
    S1_pS=S1_p*(1+5/100)*max(X);
    S2_pS=S2_p*(1+5/100)*max(X);
    
    S1_pECG=S1_p*(1+5/100)*max(ECG);
    S2_pECG=S2_p*(1+5/100)*max(ECG);
    figure('Name','Detected Heart Sounds');
    subplot(2,1,1)
    plot(t,X,'b')
    hold on
    plot(t,S1_pS,'r*')
    hold on
    plot(t,S2_pS,'g*')
    legend('sound signal','S1','S2')
    if section== "relaxed"
        title('Detected Heart Sounds- in rest');
    else
        title('Detected Heart Sounds- after exercise');
    end
    xlabel('t [sec]'); 
    ylabel('[mv] ');
    xlim([t(1) t(end)]);
    ylim([(1+5/100)*min(X) (1+20/100)*max(X)]);
    
    subplot(2,1,2)
    plot(t_ecg,ECG)
    hold on
    plot(t,S1_pECG,'r*')
    hold on
    plot(t,S2_pECG,'g*')
    legend('ECG signal','S1','S2')
    if section== "relaxed"
        title('ECG Signal- in rest');
    else
        title('ECG Signal- after exercise');
    end
    xlabel('t [sec]'); 
    ylabel('[mv] '); 
    xlim([t(1) t(end)]);
    ylim([(1+5/100)*min(ECG) (1+20/100)*max(ECG)]);
    
end

