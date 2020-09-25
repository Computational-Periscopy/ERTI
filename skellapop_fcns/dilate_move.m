function [point_cloud,inference,map_delta] = dilate_move(data,point_cloud,hyperpriors,inference)

map_delta=0;

%% pick a pixel from existing ones
[pixel,t0_new] = choose_neighbouring_point(point_cloud,hyperpriors);

%% strauss term
flag=false;
if pixel>0
    if  ~isempty(point_cloud.params{pixel})
        t0=point_cloud.params{pixel}(:,1);
        for j=1:length(t0)
            if abs(t0_new-t0(j)) <= hyperpriors.max_dist
                flag = true;
                break %only if hardconstraint
            end
        end
    end
    
    old_config = point_cloud.params{pixel};
    inference.canti_moves(3) = inference.canti_moves(3) + 1;
    
    if  ~flag && check_inside_prior(t0_new,pixel,inference)
        
        
        %% propose a peak
        [prec, mean_a, det_term] = get_GP_par(t0_new,pixel,point_cloud,data,hyperpriors,false);
        
        sigma = 1./sqrt(prec);
        a_new = mean_a + randn(size(sigma)).*sigma;
        new_config = [old_config;t0_new,a_new];
        
        %% proposal logprobability
        likelihood = compute_likelihood(pixel,new_config,point_cloud,data);
        prop_prior = -1/2*sum(prec.*(mean_a-a_new).^2) + det_term;
        
        %% non sym dilation term
        total_neigh = point_cloud.occupied_volume(pixel,t0_new);
        term = -log(point_cloud.total_points/total_neigh)-log(2*hyperpriors.Nbin+1);
        
        %% Poisson ref measure
        ref_measure = log(hyperpriors.lambda_S)-log(inference.prior_length);
        
        %% non symmetrical proposal term
        nonsym = - term - log(point_cloud.points_with_neigh+1) - 1/2*sum(log(prec)-log(2*pi)-prec.*(a_new-mean_a).^2);
        
        %% area interaction
        log_penalty = area_interaction(data,point_cloud,pixel,new_config,hyperpriors);
        
        old_likelihood = point_cloud.density(pixel);
        %% accept/reject
        if rand<exp(likelihood-old_likelihood+prop_prior+log_penalty+ref_measure+nonsym)
            %% save new estimates
            [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,false);
            
            %% compute map
            map_delta=ref_measure+likelihood-old_likelihood+log_penalty+prop_prior;
            inference.accepted_moves(3) = inference.accepted_moves(3) + 1;
            
            inference.map_delta(3) = inference.map_delta(3)+ map_delta;
        end
    end
end

end