function [R] = find_R_peaks(L,fs)
    N=length(L(:,1));
    num_of_leads=length(L(1,:));
    t = (0:N-1)/fs;
    figure('Name','ECG Data & detected QRS');
    for j= 1: num_of_leads
        X= L(:,j);
        threshold = 0.4*max(X);
        Y0= abs(X);
        Y1=zeros(N,1);
        Y2=zeros(N-1,1);
        QRS= zeros(N,1);
        R= zeros(N,1);
        for n=1:N
            if Y0(n)> threshold 
                 Y1(n)= Y0(n);
            else
                Y1(n)= threshold;
            end
            if n~=1
                Y2(n-1)= Y1(n)- Y1(n-1); %first derivitive
                if Y2(n-1)>0.02
                    QRS(n-1)=1;
                end
            end
        end

        %% locate the R waves
        start=0;
        for i=1:N-1
            if(QRS(i)~=0)
                if start==0
                    start=i;
                else
                    if QRS(i+1)==0
                        %QRS_locs(start:i)=0;
                        mid=int16((start+i)/2);
                        R(mid)=1;
                        start=0;
                    end
                end 
            end 
        end
        prev=-100;
        for i=1:N-1
            if(R(i)~=0)
                if(i-prev)<50
                    R(i)=0;
                end
                prev=i;
            end
        end

        if j==1
            R1= R;
        elseif j==2
            R2=R;
        else
            R3=R;  

        end 
        %% plot
        R_p=R(:);
        R_p(R_p==0)=nan;
        subplot(num_of_leads,1,j);
        plot(t,X)
        hold on
        plot(t,(R_p*(1+5/100)*max(X)),'r*')
        if num_of_leads>1
            legend(sprintf('Lead %d',j));
        else
            legend('Lead II');
        end
        sgtitle('Detected R waves');
        xlabel('t [sec]'); 
        ylabel('[mV]'); 
        xlim([0 (N-1)/fs]);
    end
    if num_of_leads==3
        R= [R1 R2 R3];
    else
        R= [R1];
    end
end

