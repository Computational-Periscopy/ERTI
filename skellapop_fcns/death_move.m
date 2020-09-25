function [point_cloud,inference,map_delta] = death_move(data,point_cloud,hyperpriors,inference)
%%
    map_delta = 0;
    
    [pixel,index] = choose_random_point(point_cloud);
    
    inference.canti_moves(2) = inference.canti_moves(2) + 1;
    
    new_config = point_cloud.params{pixel};
    new_config(index,:) = [];
    old_config = point_cloud.params{pixel};
    
    %% likelihood
    likelihood = compute_likelihood(pixel,new_config,point_cloud,data);
    
    %% prior
    [prec, mean_a, det_term] = get_GP_par(old_config(index,1),pixel,point_cloud,data,hyperpriors,false);
    prior = 1/2*sum((old_config(index,2:end)-mean_a).^2.*prec) - det_term;
    
    %% non symmetrical proposal term %
    sym=-log(hyperpriors.lambda_S)+log(point_cloud.total_points)+log(inference.eff_prior_length-(2*hyperpriors.max_dist+1))-log(inference.prior_length) ...
         + 1/2*sum(log(prec)-log(2*pi)-prec.*(old_config(index,2:end)-mean_a).^2);
    
    %% area interaction
    log_penalty = area_interaction(data,point_cloud,pixel,new_config,hyperpriors);

    old_likelihood = point_cloud.density(pixel);
    %% accept reject
    if rand<exp((likelihood-old_likelihood+prior+log_penalty)+sym)
        %% new map
        map_delta=likelihood-old_likelihood+prior+log_penalty-log(hyperpriors.lambda_S/inference.prior_length);

        %% save new estimates
        [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,false); %% Change to change_config
        
        inference.accepted_moves(2) = inference.accepted_moves(2) + 1;
        
        inference.map_delta(2) =inference.map_delta(2)+ map_delta;
    end
    
    if isnan(map_delta) || isinf(map_delta)
        keyboard
    end
    
    
end