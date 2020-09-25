function  [point_cloud,inference,map_delta] = mark_move(data,point_cloud,hyperpriors,inference)
%%
    map_delta = 0;
    
    
    %% choose pixel
    [pixel,index] = choose_random_point(point_cloud);
    old_config = point_cloud.params{pixel};
    new_config = old_config;
    %% choose mark
    mark = randi(3)+1;
    
    inference.canti_moves(4+mark) = inference.canti_moves(4+mark) + 1;
    
    %% random walk metropolis
    new_config(index,mark) = old_config(index,mark)+randn*inference.sigma_RWM(mark-1);
    
    %% current log probability
    likelihood = compute_likelihood(pixel,new_config,point_cloud,data);
    
    [prec, mean_a] = get_GP_par(old_config(index,1),pixel,point_cloud,data,hyperpriors,true);
    
    prior_curr = -1/2*(old_config(index,mark)-mean_a(mark-1))^2*prec(mark-1);
    
    %% proposal log_prob
    prior_prop = -1/2*(new_config(index,mark)-mean_a(mark-1))^2*prec(mark-1);
    
    old_likelihood = point_cloud.density(pixel);
    %% accept-reject
    if exp(likelihood-old_likelihood + prior_prop - prior_curr)>rand
        
        %% modify point
        [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,true); %% 
        %% map delta
        map_delta = prior_prop-prior_curr+likelihood-old_likelihood;
        inference.accepted_moves(4+mark) = inference.accepted_moves(4+mark)+1;
        inference.map_delta(4+mark) = inference.map_delta(4+mark)+map_delta;
    end
    
end