function [point_cloud,inference,map_delta] = birth_move(data,point_cloud,hyperpriors,inference)

map_delta=0;


inference.canti_moves(1) = inference.canti_moves(1) + 1;
%% pick a bin
strauss=true;
iter = 1;
while strauss && iter<20
    pixel = inference.prior_PPP(randi(length(inference.prior_PPP)));
    p=inference.T0_prior{pixel};
    t0_new=p(randi(length(p)));
    
    %% strauss term
    strauss=false;
    if ~isempty(point_cloud.params{pixel})
        t0=point_cloud.params{pixel}(:,1);
        for j=1:length(t0)
            if abs(t0_new-t0(j)) <= hyperpriors.max_dist
                strauss = true;
                break %only if hardconstraint
            end
        end
    end
    iter = iter+1;
end

% if (pixel==data.L)
%     disp('here')
% end
if ~strauss
    
    %% propose a peak
    [prec, mean_a, det_term] = get_GP_par(t0_new,pixel,point_cloud,data,hyperpriors,false);

    sigma = 1./sqrt(prec);
    a_new = mean_a + randn(size(sigma)).*sigma;
    new_config = [point_cloud.params{pixel};t0_new,a_new];
    
%     if pixel == 10
%         keyboard
%     end
    %% likelihood
    likelihood = compute_likelihood(pixel,new_config,point_cloud,data);
    
    %% priors
    delta_prior = -1/2*sum((new_config(end,2:end)-mean_a).^2.*prec) + det_term;
    
    %% non symmetrical proposal term. jacobian 1 
    sym = log(hyperpriors.lambda_S) - log(point_cloud.total_points+1)  - log(inference.eff_prior_length) + log(inference.prior_length) ...
        - 1/2*sum(log(prec)-log(2*pi)-prec.*(a_new-mean_a).^2);
    
    %% area interaction
    log_penalty = area_interaction(data,point_cloud,pixel,new_config,hyperpriors);
    old_likelihood = point_cloud.density(pixel);
    
    %% accept/reject
    if rand<exp(likelihood-old_likelihood+delta_prior+log_penalty+sym)
        
        %% save new estimates
        [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,false);
        
        %% compute map
        map_delta = likelihood-old_likelihood+delta_prior+log_penalty+log(hyperpriors.lambda_S/inference.prior_length);
        
        inference.accepted_moves(1) = inference.accepted_moves(1) + 1;
        inference.map_delta(1) =inference.map_delta(1)+ map_delta;
    end
    
    
    if isnan(map_delta) || isinf(map_delta)
        keyboard
    end
    
end

end