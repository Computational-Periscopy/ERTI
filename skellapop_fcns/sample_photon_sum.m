function phot = sample_photon_sum(y,x,b)

    p = b./(x+b);
    
    if length(y)<15
        phot = sum(binornd(y,p));
    else
        lambda = y'*p;
        if lambda>50
            phot = lambda+randn*sqrt(lambda);
            phot(phot<0) = 0;
        else
            phot = poissrnd(lambda);
        end
    end

end