function  [point_cloud,inference,map_delta] = shift_move(data,point_cloud,hyperpriors,inference)
   
%%
    map_delta=0;
    sigma_RWM = hyperpriors.Nbin/4;
  
    inference.canti_moves(5) = inference.canti_moves(5) + 1;
    [pixel,index] = choose_random_point(point_cloud);

   
    old_config = point_cloud.params{pixel};
    new_config = old_config;
    
    while new_config(index,1)==old_config(index,1)
        new_config(index,1)=round(normrnd(old_config(index,1),sigma_RWM));
    end
    
    flag = true;
    for j=1:size(new_config,1)
        if j~=index && abs(new_config(index,1)-new_config(j,1))<=hyperpriors.max_dist
            flag = false;
            break;
        end
    end
    
    if flag && check_inside_prior(new_config(index,1),pixel,inference)
       
        %% current logprobability
        likelihood = compute_likelihood(pixel,new_config,point_cloud,data);
        [prec_prior, mean_a, det_term1] = get_GP_par(old_config(index,1),pixel,point_cloud,data,hyperpriors,false);
        prior_curr = -1/2*sum((old_config(index,2:end)-mean_a).^2.*prec_prior) + det_term1;
        
        %% GP prior        
        [prec, mean_a, det_term2] = get_GP_par(new_config(index,1),pixel,point_cloud,data,hyperpriors,false);
        prior_prop = -1/2*sum((new_config(index,2:end)-mean_a).^2.*prec) + det_term2;
        
        %% area interaction
        log_penalty = area_interaction(data,point_cloud,pixel,new_config,hyperpriors);

        old_likelihood = point_cloud.density(pixel);
        %% accept reject
        if rand<exp(likelihood-old_likelihood+prior_prop-prior_curr+log_penalty)
          
            %% modify point
           [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,false); 
            
            inference.accepted_moves(5) = inference.accepted_moves(5) + 1;
            %% map delta
            map_delta=likelihood-old_likelihood+log_penalty+prior_prop-prior_curr;
            
            inference.map_delta(5) =inference.map_delta(5)+ map_delta;
        end
    end
    
end