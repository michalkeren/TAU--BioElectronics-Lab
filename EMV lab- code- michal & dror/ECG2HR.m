function [ECG_BPM,ECG_data,peaks,peak_locations_in_time] = ECG2HR(filename,time_frame)
    sample_freq=1000;
    dataDir = './';
    file_name = fopen(filename, 'rt');
    Data = textscan(file_name, repmat('%f', 1, 11), 'Delimiter','\t', 'CollectOutput', 1, 'HeaderLines',8);
    ECG_data= Data{1,1}(:,1); %we are only intrested in the left column.
    data_sq= ECG_data.^2;
%% find peaks
    [peaks,locs] = findpeaks(data_sq,'MinPeakProminence',0.4);
    peak_locations_in_time= locs/1000;
%% find BPM
    frameDiffs = diff(locs);
    timeBetweenBeats = frameDiffs./sample_freq;
    ECG_BPM = (1 ./ timeBetweenBeats) .* 60;
end

