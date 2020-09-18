function likelihood = compute_likelihood(pixel,new_config,ceiling,data)


new = get_irf(new_config,ceiling,data);

likelihood = -sum(((new-data.Y(pixel,:)').^2)./(data.Sigma2(pixel,:)'));
%likelihood = -cost(new,data.Y(pixel,:)',data.Sigma2(pixel,:)',eps);

if isnan(likelihood) || ~isreal(likelihood)
    likelihood = -Inf;
    %keyboard;
end


end