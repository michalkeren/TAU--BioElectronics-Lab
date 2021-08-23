
%% part 1-A %%
close all; clear all; clc
%%load electrodes data:
% elc_names=["AF3","F7","F3","FC5","T7","P7","O1","02","P8","T8","FC6","F4","F8","AF4"];
elc_names=["AF3","F3","FC5","P7","o1","o2","P8","T8","FC6","F4","F8","AF4"]; %took out F7 &T7
not_green=[1,12,4,5,7];
num_of_electrodes= length(elc_names);
for i=1:num_of_electrodes
    j=i-1;
    Elc(:,i)= csvread('Part-A-25.03.20.08.59.27.csv',0,j,[0,j,8999,j]);
    Elc(:,i)=Elc(:,i)-mean(Elc(:,i));
end
%%setup parameters:
N=9000;
fs= 128; %Hz;
Ts= 1/fs; %sec
Tmax= (N-1)*Ts; %the total time.  (accurding to the video it is 1.08 min)
t= 0:Ts:Tmax;
eyes_open_time= 39.7; %sec;  (accurdint to the video)
eyses_closed_time=Tmax-eyes_open_time; %sec; 
N_eyes_open= int16(eyes_open_time*fs);
%
%% alpha beta theta delta waves
% filter noise:
fl= 1; %Hz;
fh= 30; %Hz;
Elc_f= get_desired_wave(Elc,fl,fh,elc_names,fs,t,num_of_electrodes,not_green);

%segment 1:
Elc_eyes_open= Elc_f((1:N_eyes_open),:);
t_eo= t(1:N_eyes_open);
[delta_waves, delta_dominent_elc]= get_desired_wave(Elc_eyes_open,1,3.5,elc_names,fs,t_eo,num_of_electrodes,not_green);
[theta_waves, theta_dominent_elc]= get_desired_wave(Elc_eyes_open,4,7,elc_names,fs,t_eo,num_of_electrodes,not_green);
[alpha_waves, alpha_dominent_elc]= get_desired_wave(Elc_eyes_open,8,13,elc_names,fs,t_eo,num_of_electrodes,not_green);
[beta_waves, beta_dominent_elc]= get_desired_wave(Elc_eyes_open,14,30,elc_names,fs,t_eo,num_of_electrodes,not_green);

waves_seg1=[delta_waves(:,delta_dominent_elc), theta_waves(:,theta_dominent_elc), alpha_waves(:,alpha_dominent_elc), beta_waves(:,beta_dominent_elc)];
selected_elc_names= [elc_names(delta_dominent_elc),elc_names(theta_dominent_elc),elc_names(alpha_dominent_elc),elc_names(beta_dominent_elc)];
plot_waves(waves_seg1,selected_elc_names,t_eo,fs,1)

std_seg1=[std(waves_seg1(:,1)),std(waves_seg1(:,2)),std(waves_seg1(:,3)),std(waves_seg1(:,4))]

%segment 2:
Elc_eyes_closed= Elc_f((N_eyes_open+1:end),:);
t_ec= t(N_eyes_open+1:end);
delta_waves= get_desired_wave(Elc_eyes_closed,1,3.5,elc_names,fs,t_ec,num_of_electrodes,not_green);
theta_waves= get_desired_wave(Elc_eyes_closed,4,7,elc_names,fs,t_ec,num_of_electrodes,not_green);
alpha_waves= get_desired_wave(Elc_eyes_closed,8,13,elc_names,fs,t_ec,num_of_electrodes,not_green);
beta_waves= get_desired_wave(Elc_eyes_closed,14,30,elc_names,fs,t_ec,num_of_electrodes,not_green);

waves_seg2=[delta_waves(:,delta_dominent_elc), theta_waves(:,theta_dominent_elc), alpha_waves(:,alpha_dominent_elc), beta_waves(:,beta_dominent_elc)];
plot_waves(waves_seg2,selected_elc_names,t_ec,fs,2)

std_seg2=[std(waves_seg2(:,1)),std(waves_seg2(:,2)),std(waves_seg2(:,3)),std(waves_seg2(:,4))]

%change between segments
change= (std_seg2-std_seg1)./std_seg1.*100


%% ------------ part 1.B (salt bridge)-------------%%
clear all; close all; clc;

%%Opening the Elc file
Elc=load('partIII_Group6.txt','r');
Elc_names={'AF3', 'F7', 'F3', 'FC5', 'T7', 'P7', 'O1', 'O2', 'P8', 'T8','FC6', 'F4','F8', 'AF4'};%defining Elc_names' name by the Elc's order

%%setup parameters:
N=3000;
fs= 128; %Hz
Ts=1/fs; %sec
Tmax= (N-1)*Ts; %the total time.
t= 0:Ts:Tmax;

%%find the SB suspects:
for i=1:13
 P(:,i) =abs(Elc(:,i)-Elc(:,i+1));              %the potential diff between niegboring electrodes.
 %ED(i)=sum((P(:,i)-mean(P(:,i))).^2)./Tmax;     %temporal variance
 similarity(i)=length(find(P(:,i)<=100))/N;     %the relative similarity between niegboring electrodes potentials.
end

suspects= find(similarity> mean(similarity));
SB_moments= zeros(size(P));

for i =1:length(suspects)
    j=suspects(i);
    locs= find(P(:,j)<=100);
    SB_moments(locs,j)=1000;  % the moments on time where the electrodes are bridging.
end

%%plot
for i =1:length(suspects)
    j=suspects(i);
    figure;
    plot(t,Elc(:,j))
    hold on
    plot(t,Elc(:,j+1))
    hold on
    plot(t,SB_moments(:,j),'g')
    hold on
    plot(t,P(:,j),'r')
    title(Elc_names(j)+" & "+ Elc_names(j+1)) 
    ylabel('Amplitude [\muV]');
    xlabel('Time [sec]');
    legend(Elc_names{j},Elc_names{j+1},'Bridge moments','potential diff');
end