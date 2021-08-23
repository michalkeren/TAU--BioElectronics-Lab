function [ShannonEnergy] = get_ShannonEnergy(S,order)
    N=length(S);
    for i=1:N
        if order==3
            S(i)= (abs(S(i))).^3.*(log((abs(S(i))).^3));
            
        else
            S(i)= (S(i)).^2.*(log(S(i)).^2);
        end
        ShannonEnergy= -1/N*sum(S);
    end
end
