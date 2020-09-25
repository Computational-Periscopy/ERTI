function [point_cloud,inference,map_delta] = erode_move(data,point_cloud,hyperpriors,inference)

    map_delta=0;
    inference.canti_moves(4) = inference.canti_moves(4) + 1;
    
    %% pick a pixel and bin from ones with neighbors
    accepted=false;
    iter = 1;
    while ~accepted
        iter = iter +1;
        [pixel,index] = choose_random_point(point_cloud);
        if point_cloud.neigh{pixel}(index)
            accepted=true;
        end
    end
        
    %% kill the peak
    old_config = point_cloud.params{pixel};
    new_config = old_config;
    new_config(index,:) = [];
    
    %% proposal logprobability
    likelihood = compute_likelihood(pixel,new_config,point_cloud,data);

    [prec, mean_a, det_term] = get_GP_par(old_config(index,1),pixel,point_cloud,data,hyperpriors,false);
    prior = 1/2*sum(prec.*(mean_a-old_config(index,2:end)).^2) - det_term;
    
    %% non sym dilation term
    total_neigh = point_cloud.occupied_volume(pixel,old_config(index,1));
    term=-log((point_cloud.total_points+1)/(total_neigh-1))-log(2*hyperpriors.Nbin+1);
    
    %% Poisson ref measure
    ref_measure = -log(hyperpriors.lambda_S) + log(inference.prior_length);
    
    %% non symmetrical proposal term
    sym =  term ...  % dilation proposal term 
     + log(point_cloud.points_with_neigh) ...% erosion proposal term 
     + 1/2*sum(log(prec)-log(2*pi)-prec.*(old_config(index,2:end)-mean_a).^2);
    
    %% area interaction
    log_penalty = area_interaction(data,point_cloud,pixel,new_config,hyperpriors);

    
    old_likelihood = point_cloud.density(pixel);
    %% accept reject
    if rand<exp(ref_measure+likelihood-old_likelihood+prior+log_penalty+sym)

        %% save new estimates
        [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,false); %% Change to change_config

        %% map delta
        map_delta= likelihood-old_likelihood+log_penalty+ref_measure+prior;
        
       
        inference.accepted_moves(4) = inference.accepted_moves(4) + 1;
    
        inference.map_delta(4) =inference.map_delta(4)+ map_delta;
    end
    
end