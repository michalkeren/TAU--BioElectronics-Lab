fs =100;
relax_time_windows= zeros(10,2);
fear_time_windows= zeros(10,2);
for i =1:10
    if i==10
        file='sub-10_eeg_sub-10_task-ImaginedEmotion_events.tsv';
    else
        file= sprintf('sub-0%d_eeg_sub-0%d_task-ImaginedEmotion_events.tsv',i,i);
    end
    events=tdfread(file);
    event_val= deblank(string(events.value));
    event_t= events.onset;
    relax_idx= find(event_val(:,1) == "relax");
    anger_idx= find(event_val(:,1) == "fear");
    exit_idx= find(event_val(:,1) == "exit");
    exit_idx= exit_idx(exit_idx > anger_idx);
    relax_time_windows(i,1)= event_t(relax_idx);
    relax_time_windows(i,2)= event_t(relax_idx+1);
    fear_time_windows(i,1)= event_t(anger_idx+1);
    fear_time_windows(i,2)= event_t(exit_idx(1)); 
    
end

%% extract Features:
Features(1:10,9)= "Relaxation";
Features(11:20,9)= "Fear"; 
for i=1:10
    switch i
        case 1
            sub= sub1(:,:);
        case 2
            sub= sub1(:,:);
        case 3
            sub= sub3(:,:);
        case 4
            sub= sub4(:,:);
        case 5
            sub= sub5(:,:);
        case 6
            sub= sub6(:,:);
        case 7
            sub= sub7(:,:);
        case 8
            sub= sub8(:,:);
        case 9
            sub= sub9(:,:);
        otherwise
            sub= sub10(:,:);
    end 
    sub_times= sub.Time;
    sub_CI1= sub.VarName2;
    sub_CI2= sub.VarName3;
    %%relax:
    idx= find(and(sub_times>= relax_time_windows(i,1),sub_times<= relax_time_windows(i,2)));
    sub_CI1_r =sub_CI1(idx);
    sub_CI2_r= sub_CI2(idx);
    [Features(i,1),Features(i,2),Features(i,3),Features(i,4)]= get_std_of_4_brain_waves(sub_CI1_r,fs);
    [Features(i,5),Features(i,6),Features(i,7),Features(i,8)]= get_std_of_4_brain_waves(sub_CI2_r,fs);   
    %%fear:
    j=10+i;
    t_start= fear_time_windows(i,1);
    t_end=fear_time_windows(i,2);
    idx= find(and(sub_times>= t_start,sub_times<= t_end));
    sub_CI1_a =sub_CI1(idx);
    sub_CI2_a= sub_CI2(idx);
    [Features(j,1),Features(j,2),Features(j,3),Features(j,4)]= get_std_of_4_brain_waves(sub_CI1_a,fs);
    [Features(j,5),Features(j,6),Features(j,7),Features(j,8)]= get_std_of_4_brain_waves(sub_CI2_a,fs); 
end
writematrix(Features,'Features.csv')
    



