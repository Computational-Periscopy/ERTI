function [point_cloud,inference,md] = sample_ceiling(point_cloud,data,inference,hyperpriors)

md = 0;

inference.canti_moves(11) = inference.canti_moves(11) + 1;
new_ceil = point_cloud.ceiling;
new_ceil.height = point_cloud.ceiling.height + randn*inference.sigma_RWM_hceil;
new_ceil.refl = point_cloud.ceiling.refl + randn*inference.sigma_RWM_rceil;

if new_ceil.refl>0
    likelihood = zeros(data.L,1);

    for l=1:data.L
        likelihood(l) = compute_likelihood(l,point_cloud.params{l},new_ceil,data);
    end

    delta_prior = gamma_pdf(new_ceil.height,hyperpriors.k_hceil,hyperpriors.theta_hceil)- ...
        gamma_pdf(point_cloud.ceiling.height,hyperpriors.k_hceil,hyperpriors.theta_hceil);

    delta_prior = delta_prior + gamma_pdf(new_ceil.refl,hyperpriors.k_rceil,hyperpriors.theta_rceil)-...
        gamma_pdf(point_cloud.ceiling.refl,hyperpriors.k_rceil,hyperpriors.theta_rceil);


    s_likelihood = sum(likelihood-point_cloud.density);
    if rand<exp(s_likelihood+delta_prior)
        point_cloud.ceiling = new_ceil;
        md = s_likelihood+delta_prior;

        inference.accepted_moves(11) = inference.accepted_moves(11) + 1;
        inference.map_delta(11) = inference.map_delta(11)+ md;

        for l=1:data.L
            point_cloud.density(l) = likelihood(l);
        end
    end
end

end