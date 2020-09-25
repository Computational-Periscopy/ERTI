function  [point_cloud,inference,map_delta] = merge_move(data,point_cloud,hyperpriors,inference)

map_delta = 0;
%% pick a pixel

inference.canti_moves(10) = inference.canti_moves(10) + 1;
        
flag = true;

while flag
    [pixel,index] = choose_merge_point(point_cloud);
    if size(point_cloud.params{pixel},1)>1
       index2 = index;
       while index2 == index
            index2 = randi(size(point_cloud.params{pixel},1));
       end
       flag = false; 
    end
end

old_config = point_cloud.params{pixel};
new_config = old_config;
new_config([index,index2],:) = [];


[w1,w2] = compute_merge_weights(old_config(index,:),old_config(index2,:));


new_t0 = round(old_config(index,1)*w1+old_config(index2,1)*w2);

flag = false;
for j=1:size(new_config,1)
    if abs(new_t0-new_config(j,1))<=hyperpriors.max_dist
        flag = true;
        break %only if hardconstraint
    end
end

if ~flag
    %% new peak
    new_r = log(w1*exp(old_config(index,2))+w2*exp(old_config(index2,2)));
    new_h = log(w1*exp(old_config(index,3))+w2*exp(old_config(index2,3)));
    new_alpha = inv_fun_alpha(w1*fun_alpha(old_config(index,4))+w2*fun_alpha(old_config(index2,4)));
    
    delta = zeros(1,4);
    delta(1) = old_config(index2,1)-old_config(index,1);
    delta(2) = exp(old_config(index2,2))-exp(old_config(index,2));
    delta(3) = exp(old_config(index2,3))-exp(old_config(index,3));
    delta(4) = fun_alpha(old_config(index2,4))-fun_alpha(old_config(index,4));
    
    new_config = [new_config;new_t0,new_r,new_h,new_alpha];
    
    if sum(~isreal(new_config))
        keyboard
    end
    %% likelihood
    likelihood = compute_likelihood(pixel,new_config,point_cloud,data);
    
    %% proposal logprobability
    [prec, mean_a, det_term] = get_GP_par(new_config(end,1),pixel,point_cloud,data,hyperpriors,false);
    prop= -1/2*sum((new_config(end,2:end)-mean_a).^2.*prec)+det_term;
    
    %% current logprobability
    [prec1, mean_a1, det_term1] = get_GP_par(old_config(index,1),pixel,point_cloud,data,hyperpriors,false);
    [prec2, mean_a2, det_term2] = get_GP_par(old_config(index2,1),pixel,point_cloud,data,hyperpriors,false);
    
    curr = - 1/2*sum((old_config(index,2:end)-mean_a1).^2.*prec1)+det_term1-1/2*sum((old_config(index2,2:end)-mean_a2).^2.*prec2)+det_term2;
    %% poisson ref meas
    ref_meas = -log(hyperpriors.lambda_S)+log(inference.prior_length);
    
    %% non symmetrical proposal term
    % jacobian 
    sym = -log(point_cloud.total_points-point_cloud.sum_PPP(1))+log(point_cloud.total_points+1)+ ...
        gauss_pdf(delta,inference.merge_sigmas)+merge_jacobian(old_config(index,:),old_config(index2,:));
    
    %% area interaction
    log_penalty = area_interaction(data,point_cloud,pixel,new_config,hyperpriors);
    old_likelihood = point_cloud.density(pixel);
    
    %% accept reject
    if rand<exp(likelihood-old_likelihood+prop-curr+ref_meas+log_penalty+sym)
        
        %% map delta
        map_delta=likelihood-old_likelihood+prop-curr+log_penalty+ref_meas;
        
        %% save new estimates
        [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,false); %% Change to change_config
        
        inference.map_delta(10) = inference.map_delta(10)+map_delta;
        inference.accepted_moves(10) = inference.accepted_moves(10) + 1;
    end
end
if isinf(map_delta)
    keyboard
end

end