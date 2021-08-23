function [s_delta,s_theta,s_alpha,s_beta] = get_std_of_4_brain_waves(X,fs)
    elc_names=["AF3","F3","FC5","P7","o1","o2","P8","T8","FC6","F4","F8","AF4"]; 
    delta_waves= get_desired_wave(X,1,3.5,elc_names,fs,0,0,[]);
    theta_waves= get_desired_wave(X,4,7,elc_names,fs,0,0,[]);
    alpha_waves= get_desired_wave(X,8,13,elc_names,fs,0,0,[]);
    beta_waves= get_desired_wave(X,14,30,elc_names,fs,0,0,[]);
    s_delta= std(delta_waves);
    s_theta= std(theta_waves);
    s_alpha= std(alpha_waves);
    s_beta= std(beta_waves);
end

