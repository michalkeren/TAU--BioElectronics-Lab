function [locs] = find_peaks_locations(X,padding,Threshold)
    j=1;
%     locs=[];
    i=2;
    while i<=length(X)-1
        prev= X(i-1);
        next=X(i+1);
        curr=X(i);
        if and(and(curr>=Threshold, curr>prev), curr>next)
            locs(j)=i;
            j=j+1;
            i=i+padding;
        else
            i=i+1;
        end
    end
end

