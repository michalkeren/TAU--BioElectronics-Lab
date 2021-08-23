function [] = plot_waves(W,elc_names,t,fs,seg)
%% time domain:
    names =["\delta",'\theta','\alpha','\beta'];
    figure()
    for i=1:4
       subplot(4,1,i)
       plot(t,W(:,i))
%        hold on
%        plot(t,ones(size(W(:,i)))*mean(W(:,i)),'r')
%        hold on
%        plot(t,ones(size(W(:,i)))*std(W(:,i)),'g')
%        hold on
%        plot(t,ones(size(W(:,i)))*-std(W(:,i)),'g')
       title(names(i)+"- Wave, according to elc: "+elc_names(i))
       xlabel('t [sec]'); 
       ylabel('[\muV]');
       xlim([t(1) t(end)]);
%        legend('the wave','mean','\sigma','-\sigma')
       if seg==1
           sgtitle('Segment #1 - Eyes open');
       else
          sgtitle('Segment #2 - Eyes closed');
       end
    end
%% freq domain
    figure()
    fft_W= abs(fft(W));
    f = linspace(0, 1, fix(length(t)/2)+1)*(fs/2); % freq vec
    If = 1:length(f); %the relevent indexes
    for i=1:4
       subplot(4,1,i)
       plot(f,db(fft_W(If,i)))
%        hold on
%        plot(f,ones(size(fft_W(If,i)))*40,'r')
       title(names(i)+"- Wave, according to elc: "+elc_names(i))
       xlabel('f [Hz]');  
       ylabel('[dB]');
       xlim([0 50]);
       if seg==1
           sgtitle('Segment #1 - Eyes open');
       else
          sgtitle('Segment #2 - Eyes closed');
       end
    end
end

