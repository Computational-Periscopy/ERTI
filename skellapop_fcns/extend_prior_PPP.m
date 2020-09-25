 function inference = extend_prior_PPP(inference)

big_prior = zeros(sum(inference.prior_PPP),1);

k=1;
for i=1:length(inference.prior_PPP)
    big_prior(k:k+inference.prior_PPP(i)-1)=i;
    k=k+inference.prior_PPP(i);
end   

inference.prior_PPP = big_prior;

end