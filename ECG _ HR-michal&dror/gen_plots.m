function [] = gen_plots(Leads,filterd_Leads,fs,delay)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here 
    N=length(Leads(:,1)); 
    t=(0:N-1)/fs;
    filtered_t=(t*fs-delay)/fs;
    j=[1 3 5];
    %% time domain
    figure('Name','ECG Data in time domain');
    for i =1:3
        subplot(3,2,j(i)); 
        plot(t,Leads(:,i));
        hold on
        plot(filtered_t,filterd_Leads(:,i),'r'); 
        legend('original','filttered')
        title(sprintf('Lead %d',i))
        xlabel('t [sec]'); 
        ylabel('Amplitude [mV]'); 
        xlim([0 (N-1)/fs]);
        %zoom in 
        subplot(3,2,j(i)+1);
        plot(t(3000:6000),Leads(3000:6000,i));
        hold on
        plot(filtered_t(2000:7000),filterd_Leads(2000:7000,i),'r');
        legend('original','filttered')
        title(sprintf('Zoom in- Lead %d',i))
        xlabel('t [sec]'); 
        ylabel('Amplitude [mV]'); 
        xlim([7 12]);
        sgtitle('ECG data in time');
    end 
%% frequancy domain
    FT_Leads= abs(fft(Leads));
    FT_filterd_Leads=abs(fft(filterd_Leads));
    Fv = linspace(0, 1, fix(length(t)/2)+1)*(fs/2); % frequency vector
    Iv = 1:length(Fv); %the relevent indexes
    figure('Name','ECG Data in frequancy domain');
    for i =1:3
        subplot(3,2,j(i)); 
        plot(Fv,FT_Leads(Iv,i));
        xlabel('f [Hz]'); 
        ylabel('Amplitude [mV]');
        xlim([0 55]);
        ylim([0 400]);
        legend(sprintf('Lead %d',i))
        %filttered
        subplot(3,2,j(i)+1);
        plot(Fv,FT_filterd_Leads(Iv,i),'r');
        xlim([0 55]);
        ylim([0 400]);
        legend(sprintf('Lead %d- filtered',i))
        xlabel('f [Hz]'); 
        ylabel('Amplitude [mV]');
        sgtitle('Original Spectrum  VS. Filtered Spectrum');
    end 
    %% Validate E.Law
    L2_test= Leads(:,1)+Leads(:,3);
    E=L2_test-Leads(:,2);
    figure('Name','Validate E.Law');
    subplot(2,1,1)
    plot(t,Leads(:,2),'r')
    hold on
    plot(t,L2_test,'b')
    xlabel('t [sec]'); 
    ylabel('Amplitude [mV]'); 
    xlim([0 (N-1)/fs]);
    legend('LEAD 1 +LEAD 3','LEAD 2')
    subplot(2,1,2)
    plot(t,E)
    legend('(LEAD 1 +LEAD 3)-LEAD 2')
    xlabel('t [sec]'); 
    ylabel('Amplitude [mV]');
    xlim([0 (N-1)/fs]);
    sgtitle('Validation of Einthoven law')
end

