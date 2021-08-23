function [Leads,filterd_Leads, fs,delay] = get_filtered_ECG(ecg_file_name,time_len,plot)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    [L1, L3, L2] =textread(ecg_file_name,'%f %f %f');
%     file_name = fopen(ecg_file_name, 'rt');
%     Data = textscan(file_name, repmat('%f', 1, 11), 'Delimiter','\t', 'CollectOutput', 1, 'HeaderLines',8);
%     L1= Data{1,1}(:,1); %lead 1
%     L3= Data{1,1}(:,2); %lead 3
%     L2= Data{1,1}(:,3); %lead 2
    Leads =[L1 L2 L3];
    N=length(Leads(:,1));
    fs= length(L1)/time_len; %[1/sec] 
    t=(0:N-1)/fs;
    %BPF
    f_L=8;   %low cut frequency in Hz
    f_H=50;   %high cut frequency in Hz
    bpf=fir1(1500,[f_L f_H]/(fs/2));
    delay=mean(grpdelay(bpf));
    filtered_t=(t*fs-delay)/fs;
    filterd_Leads= filter(bpf,1,Leads);
    %% plots 
    if plot==1
        j=[1 3 5];
        %% time domain
        figure('Name','ECG Data in time domain');
        for i =1:3
%             filterd_Leads(:,i)= filter(bpf,1,Leads(:,i));
            subplot(3,2,j(i)); 
            plot(t,Leads(:,i)); 
            subplot(3,2,j(i)+1);
            plot(t,filterd_Leads(:,i)); 
        end 
%         figure('Name','few cycles of ECG Datain time domain');
%         for i =1:3
%             filterd_Leads(:,i)= filter(bpf,1,Leads(:,i));
%             subplot(3,2,j(i)); 
%             plot(t(3000:6000),Leads(3000:6000,i)); 
%             hold on
%             plot(filtered_t(3000:6000),Leads(3000:6000,i));
%             subplot(3,2,j(i)+1);
%             plot(t(3000:6000),filterd_Leads(3000:6000,i)); 
%         end 
%             figure('Name','few cycles of ECG Datain time domain');
%         for i =1:3
%             filterd_Leads(:,i)= filter(bpf,1,Leads(:,i));
%             subplot(3,2,j(i)); 
%             plot(t(1:6000),Leads(1:6000,i)); 
%             subplot(3,2,j(i)+1);
%             plot(filtered_t(1:6000),filterd_Leads(1:6000,i)); 
%         end 
    %% frequancy domain
        f_Leads= abs(fft(Leads));
        f_filterd_Leads=abs(fft(filterd_Leads));
        df = fs/N;                      % hertz
        f = -fs/2:df:fs/2-df; 
%         f= fs/2*(0:(N/2));
        figure('Name','ECG Data in frequancy domain');
        for i =1:3
            subplot(3,2,j(i)); 
            scatter(f,f_Leads(:,i));
            xlim([0 80]);
            subplot(3,2,j(i)+1);
            scatter(f,f_filterd_Leads(:,i));
            xlim([0 80]);
        end 
    end 
end

