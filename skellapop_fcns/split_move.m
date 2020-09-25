function [point_cloud,inference,map_delta] = split_move(data,point_cloud,hyperpriors,inference)

map_delta=0;
[pixel,index] = choose_random_point(point_cloud);
inference.canti_moves(9) = inference.canti_moves(9) + 1;

%% propose 2 peaks
old_config = point_cloud.params{pixel};
new_config = old_config;
new_config(index,:) = [];

delta = inference.merge_sigmas.*randn(1,4);


%% find weights (iterative fixed point calculation)
w1 = 0.5;
t0 =old_config(index,1);
r0 = exp(old_config(index,2));
for i=1:10
    aux = (t0+(1-w1)*delta(1))/(t0-w1*delta(1));
    aux = aux^2*(r0-w1*delta(2))/(r0-(1-w1)*delta(2));
    w1_p = 1/(1+aux);
    if abs(w1-w1_p)<1e-3
        break;
    end
    w1 = w1_p;
end

%% propose split
if delta(1)>hyperpriors.max_dist && w1>0 && w1<1
    w2 = 1-w1;
    t0_new_1 = round(old_config(index,1)+w2*delta(1));
    t0_new_2 = round(old_config(index,1)-w1*delta(1));
    new_r = log(exp(old_config(index,2))+w2*delta(2));
    new_r2 = log(exp(old_config(index,2))-w1*delta(2));
    new_h = log(exp(old_config(index,3))+w2*delta(3));
    new_h2 = log(exp(old_config(index,3))-w1*delta(3));
    new_alpha = inv_fun_alpha(fun_alpha(old_config(index,4))+w2*delta(4));
    new_alpha2 = inv_fun_alpha(fun_alpha(old_config(index,4)-w1*delta(4)));
    
    flag=false;
    for j=1:size(new_config,1)
        if abs(t0_new_2-new_config(j,1))<=hyperpriors.max_dist || abs(t0_new_1-new_config(j,1))<=hyperpriors.max_dist
            flag=true;
            break
        end
    end
    
    if  ~flag && sum((t0_new_2-inference.T0_prior{pixel})==0) && sum((t0_new_1-inference.T0_prior{pixel})==0)  ...%if the proposal lies inside the prior
            && isreal(new_r) && isreal(new_r2) && isreal(new_h) && isreal(new_h2)&& isreal(new_alpha) && isreal(new_alpha2)
        
        new_config = [new_config;t0_new_1,new_r,new_h,new_alpha;t0_new_2,new_r2,new_h2,new_alpha2];
        %% likelihood
        likelihood = compute_likelihood(pixel,new_config,point_cloud,data);
        
        %% proposal logprobability
        [prec, mean_a, det_term] = get_GP_par(t0_new_1,pixel,point_cloud,data,hyperpriors,false);
        [prec_2, mean_a_2, det_term2] = get_GP_par(t0_new_2,pixel,point_cloud,data,hyperpriors,false);
        
        prop = -sum((new_config(end-1,2:end)-mean_a).^2.*prec)/2+det_term-sum((new_config(end,2:end)-mean_a_2).^2.*prec_2)/2+det_term2;
        
        %% current logprobability
        [prec, mean_a, det_term] = get_GP_par(old_config(index,1),pixel,point_cloud,data,hyperpriors,false);
        curr= - sum((old_config(index,2:end)-mean_a).^2.*prec)/2 + det_term;
        
        %% poisson ref meas
        ref_meas = log(hyperpriors.lambda_S)-log(inference.prior_length);
        
        %% non symmetrical proposal term
        %jacobian 1/((u1-u1^2)(u2-u2^2)) (TODO add angle term)
        sym = log(point_cloud.total_points-point_cloud.sum_PPP(1)+1)-log(point_cloud.total_points)- ...
            gauss_pdf(delta,inference.merge_sigmas)-merge_jacobian(new_config(end-1,:),new_config(end,:));
        
        %% area interaction
        log_penalty = area_interaction(data,point_cloud,pixel,new_config,hyperpriors);
        
        old_likelihood = point_cloud.density(pixel);
        %% accept/reject
        if rand < exp(likelihood-old_likelihood+prop+ref_meas-curr+log_penalty+sym)
            
            %% save new estimates
            [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,false);
            inference.accepted_moves(9) = inference.accepted_moves(9) + 1;
            %% compute map
            map_delta=likelihood-old_likelihood+prop-curr+log_penalty+ref_meas;
            
            inference.map_delta(9) =inference.map_delta(9)+ map_delta;
        end
        
        if ~isreal(map_delta)
            keyboard
        end
    end
    
end

end