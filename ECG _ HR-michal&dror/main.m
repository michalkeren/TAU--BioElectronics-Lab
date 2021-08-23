%main:
dataDir = './';
%% -------------PART 1--------------
close all
clear all
clc

total_time_len= 51.25; %[sec]
sit_time_len= 32; %[sec]
stand_time_len= total_time_len-sit_time_len;

% load ECG file:
[original_leads, filterd_Leads,fs,delay] =get_filtered_ECG('part1.txt',total_time_len,0);
gen_plots(original_leads,filterd_Leads,fs,delay);


R= find_R_peaks(filterd_Leads,fs);
% R=[R1 R2 R3];

% HR values for lead 3:
% siting
N_sitting= int16(fs*sit_time_len); % number of samples when sitting
sit_samples= 1:N_sitting;
HR= get_HR(R(sit_samples,3),fs);
mean_HR_sit = mean(HR)
sd_HR_sit = std(HR)
%regular breathing
N_stand1= int16(fs*10); % number of samples
stand1_samples= (N_sitting):(N_sitting+N_stand1);
HR1= get_HR(R(stand1_samples,3),fs);
%stand- deep breathing
N_stand2= int16(fs*(stand_time_len-10)); % number of samples
stand2_samples= (N_sitting+N_stand1):(N_sitting+N_stand1+N_stand2);
HR2= get_HR(R(stand2_samples,3),fs);
%statistics:
population_size= min(length(HR1), length(HR2));
mean_HR_stand1 = mean(HR1(1:population_size))
sd_HR_stand1 = std(HR1(1:population_size))
mean_HR_stand2 = mean(HR2(1:population_size))
sd_HR_stand2 = std(HR2(1:population_size))
[h,p] = ttest2(HR1(1:population_size),HR2(1:population_size),'Vartype','unequal')
%% -------------PART 2--------------
close all
clear all
clc
time_len= 70.45; %[sec]
% load ECG file:
[Leads,filterd_Leads,fs,delay] =get_filtered_ECG("part2.txt",time_len,0);
N_start= int16(10*fs); %trim 10sec from begenninig
N_end=int16((time_len-10)*fs); %trim 10sec from the end
trimed_sampels= N_start:N_end;
Lead= filterd_Leads(trimed_sampels,3); %lead 3.
R= find_R_peaks(Lead,fs); %%fix time
HR=get_HR(R,fs);
mean_HR=mean(HR)
std_HR=std(HR)

%plot 15 beats
figure()
x= 34:48;
plot(x,HR(x),'bo')
hold on
plot(x,ones(size(HR(x)))*mean_HR,'r')
hold on
plot(x,ones(size(HR(x)))*(mean_HR+std_HR),'g')
hold on
plot(x,ones(size(HR(x)))*(mean_HR-std_HR),'g')
legend('HR','mean HR','mean HR +- std')
sgtitle('15 heart beats');
xlabel('beat index'); 
ylabel('[BPM]'); 
xlim([33 49]);

%break the ECG signal into cycles:
R_locs= find(R==1);
samples_before=int16(200/1000*fs); 
samples_after=int16(300/1000*fs);

Cycels= zeros(length(R_locs),samples_before+samples_after+1); 
for i=1:length(R_locs)
    if samples_before < R_locs(i)&&(samples_after+R_locs(i))< length(Lead)
        rel_samples=(R_locs(i)-samples_before):(R_locs(i)+samples_after);
        cell=Lead(rel_samples);
        Cycels(i,:)=cell;
    end
end
%a- the avrage cycle
avg_cycle=sum(Cycels(2:76,:), 1)/75; %ignore the first cycle.
%b- 3 subplots
figure('Name','3 ECG cycles');
t= linspace(0,500,251);
subplot(3,1,1)
plot(t,avg_cycle)
title('Avrage ECG Cycle');
xlabel('t [msec]'); 
ylabel('Amplitude [mv]'); 
subplot(3,1,2)
plot(t,Cycels(2,:))
title('First ECG Cycle');
xlabel('t [msec]');
ylabel('Amplitude [mv]'); 
subplot(3,1,3)
plot(t,Cycels(76,:))
title('Last ECG Cycle');
xlabel('t [msec]'); 
ylabel('Amplitude [mv]'); 
%c
segment=230:251; 
segment_in_time= length(segment)/fs*1000 %msec
mean_iso_line=[mean(avg_cycle(segment)) mean(Cycels(2,(segment))) mean(Cycels(76,(segment)))]
std_iso_line=[std(avg_cycle(segment)) std(Cycels(2,(segment))) std(Cycels(76,segment))]
%compering the avrage cycle to the first:
avg_val= max(avg_cycle)/std_iso_line(1)
first_val= max(Cycels(2,:))/std_iso_line(2)
figure('Name','SNR comparison');
subplot(2,1,1)
plot(t,avg_cycle)
hold on
plot(t,Cycels(2,:),'r')
legend('Avrage cycle','First cycle')
title('Original ECG Cycle');
xlabel('t [msec]'); 
ylabel('[mv]'); 
subplot(2,1,2)
plot(t,avg_cycle/std_iso_line(1))
hold on
plot(t,Cycels(2,:)/std_iso_line(2),'r')
legend('Avrage cycle Devided by STD ','First cycle Devided by STD')
title('Improved ECG Cycle');
xlabel('t [msec]');
ylabel('[mv/mv]'); 
sgtitle('SNR Improvement - comparison');

figure('Name','SNR Improvement');
subplot(2,1,1)
plot(t,avg_cycle)
hold on
plot(t,avg_cycle/std_iso_line(1),'r')
legend('Original[mv]','Devided by STD [mv/mv]')
title('Avrage ECG Cycle');
xlabel('t [msec]'); 
ylabel('[mv] or [mv/mv]');  
subplot(2,1,2)
plot(t,Cycels(2,:))
hold on
plot(t,Cycels(2,:)/std_iso_line(2),'r')
legend('Original [mv]','Devided by STD [mv/mv]')
title('First ECG Cycle');
xlabel('t [msec]');
ylabel('[mv] or [mv/mv]');
sgtitle('SNR Improvement')


%% -------------PART 3--------------
close all
clear all
clc

time_len= 33.7; %[sec]

f_c = importdata('Part3.txt');
sounds = f_c.data(:,1);
LeadII_original = f_c.data(:,2);
N = length(LeadII_original);
dt = time_len./N;
t = 0:dt:dt*(N-1);
fs=1/dt;

[b,a]=fir1(1500,[8 50]/(fs/2));
LeadII= filter(b,a,LeadII_original);
delay=mean(grpdelay(b));
t_filt=(t*fs-delay)/fs;

% the algo from the paper
[c,l] = wavedec(sounds,5,'db6'); %1-D wavelet decomposition
sounds = waverec(c,l,'db3'); %1-D wavelet reconstruction
sounds = waverec(c,l,'db4'); %1-D wavelet reconstruction
sounds = waverec(c,l,'db5'); %1-D wavelet reconstruction
E_hs = zeros(1,length(sounds));
for i=1:(length(sounds)-32)
    E_hs(i)=get_ShannonEnergy(sounds(i:i+31),2);
    i=i+16;
end 
P_hs = zeros(1,length(sounds));
for j=1:(length(E_hs))
    P_hs(j)=(E_hs(j)-mean(E_hs))./std(E_hs);
    j=j+1;
end
%


%split to relax or exercise:
N1= 21*fs;
N2=(time_len-21)*fs;
SE1= E_hs(1:N1);
SE2= E_hs(N1:(N1+N2));
sound_relax= sounds(1:N1);
sound_exercise= sounds(N1:(N1+N2));
LeadII_relax=LeadII(1:N1);
LeadII_exercise=LeadII(N1:(N1+N2));
t_relax=t(1:N1);
t_exercise=t(N1:(N1+N2));
t_filt_relax=t_filt(1:N1);
t_filt_exercise=t_filt(N1:(N1+N2));

%relaxed
[S1_relax, S2_relax, R_S1, R_S2, s1_s2, s2_s1]= find_S1_S2(sound_relax,0.8,70,LeadII,t_relax,t_filt,"relaxed");
R_waves_relax= find_R_peaks(LeadII_relax,fs);
HR= get_HR(R_waves_relax,fs);

% results:
HR_relax= [mean(HR), std(HR) ]
R_S1_relax= [mean(R_S1) ,  std(R_S1)]
R_S2_relax=[mean(R_S2) ,  std(R_S2)]
s1_s2_relax=[mean(s1_s2) ,  std(s1_s2)]
s2_s1_relax=[mean(s2_s1) ,  std(s2_s1)]

%exercise
[S1_exercise ,S2_exercise, R_S1, R_S2, s1_s2, s2_s1]= find_S1_S2(sound_exercise,1,50,LeadII_exercise,t_exercise,t_filt_exercise',"exercise");
R_waves_exercise= find_R_peaks(LeadII_exercise,fs);
HR= get_HR(R_waves_exercise,fs);
% results:
HR_exercise= [mean(HR), std(HR) ]
R_S1_exercise= [mean(R_S1) ,  std(R_S1)]
R_S2_exercise=[mean(R_S2) ,  std(R_S2)]
s1_s2_exercise=[mean(s1_s2) ,  std(s1_s2)]
s2_s1_exercise=[mean(s2_s1) ,  std(s2_s1)]

% change from rest to exercise:

HR_change = -(HR_relax(1)-HR_exercise(1))/HR_relax(1)*100
R_S1_change= -(R_S1_relax(1)-R_S1_exercise(1))/R_S1_relax(1)*100
R_S2_change = -(R_S2_relax(1)-R_S2_exercise(1))/R_S2_relax(1)*100
s1_s2_change= -(s1_s2_relax(1)-s1_s2_exercise(1))/s1_s2_relax(1)*100
s2_s1_change= -(s2_s1_relax(1)-s2_s1_exercise(1))/s2_s1_relax(1)*100

%plot ECG

% figure()
% plot(t_filt,LeadII)
% title(sprintf('ECG- LeadII signal',i))
% xlabel('t [sec]'); 
% ylabel('Amplitude [mV]'); 
% xlim([0 t_filt(end)]);

