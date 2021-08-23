function [Elc_f,dominent_elc] = get_desired_wave(Elc,fl,fh,elc_names,fs,t,num_of_electrodes,not_green)
    close all
    %% filter
    f = linspace(0, 1, fix(length(t)/2)+1)*(fs/2); % frequency vector
    Iv = 1:length(f); %the relevent indexes
    fft_Elc= abs(fft(Elc));
    [a,b] =fir1(150, [fl fh]/(fs/2));
    delay = mean(grpdelay(a));
    filtered_t=(t*fs-delay)/fs;

    Elc_f= filter(a,b,Elc);
    fft_Elc_f=abs(fft(Elc_f));
    %% find diminent electrode
    S= max(fft_Elc_f);
    for i=1:length(not_green)
        S(not_green(i))=0;
    end
    
    [max_eng ,dominent_elc] = max(S);
    dominent_elc_name= elc_names(dominent_elc);
    
    %%plot
    for i=1:num_of_electrodes
        figure();
        %time domain
        subplot(2,1,1)
        plot(t,Elc(:,i))
        hold on
        plot(filtered_t,Elc_f(:,i))
        legend('original','filtered')
        xlim([0 t(end)]);
        xlabel('t [sec]'); 
        ylabel('Amplitude[\muV]');

        %freq domain
        subplot(2,1,2)
        plot(f,fft_Elc(Iv,i))
        xlabel('f [Hz]'); 
        ylabel('Amplitude [\muV]');
        hold on
        plot(f,fft_Elc_f(Iv,i))

        xlabel('f [Hz]'); 
        ylabel('Amplitude[\muV]');
        legend('original','filtered')
        xlim([0 60]);
%         ylim([0 500])
        sgtitle(elc_names(i))
    end
end

