function [HR] = get_HR(R,fs)
 %% calc the  HR
    R_locs=find(R==1);
    RR_sample_diff = diff(R_locs);
    RR = RR_sample_diff./fs; 
    HR= (1 ./ RR) .* 60;
end

