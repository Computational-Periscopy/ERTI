function point_cloud_map = PointProcess_RJMCMC(data,point_cloud,hyperpriors,inference)

disp('------- NEW SCALE ------')
disp([' MEAN SNR ' num2str(max([0,mean(mean((data.Y.^2)./data.Sigma2,2))-1]),2)]);

%% Storage
inference.Nmc = inference.iterations*data.L;
inference.Nbi = round(inference.Nmc/2);
inference.max_map= -Inf; 
inference.max_ppp = 10;
log_map = zeros(inference.Nmc,1);
log_lhood = zeros(inference.Nmc,1);
inference.accepted_moves = zeros(1,11);
inference.map_delta = zeros(1,11);
inference.canti_moves = zeros(1,11);

%% posterior histograming
inference.build_histograms = false;
inference.histogram = zeros(1,4);
pix_fit = 1:data.L; % pixels to plot fit

%% mark move proposal 
% [ref,height,angle]
inference.sigma_RWM = ones(1,3); %sqrt(hyperpriors.alpha);
inference.sigma_RWM(1) = inference.sigma_RWM(1)/2;

%% ceiling move proposal
% inference.sigma_RWM_hceil = .02;
% inference.sigma_RWM_rceil = .02;

%% birth proposal
% reflect
% inference.k_r = 2;
% inference.theta_r = 1;
% % height
% inference.k_h = 3;
% inference.theta_h = 1;
% % angle
% inference.b1_alpha = 1;
% inference.b2_alpha = 3;

%% merge proposal
inference.merge_sigmas = [2*hyperpriors.Nbin,2,2,pi/6];

%% Matched filter prior
inference.prior_PPP = cellfun(@length,inference.T0_prior); % candidate points per pixel
inference.prior_length = sum(inference.prior_PPP);
inference.eff_prior_length = inference.prior_length;

%% Initialize variables
hyperpriors.max_dist = 2*hyperpriors.Nbin+1;
point_cloud = init_all(point_cloud,data,inference,hyperpriors);
inference = extend_prior_PPP(inference);

%% move probabilties
% mark shift birth death dilate erode split merge ceiling
% I removed the sampling of the ceiling due to the model mismatch
inference.p_moves = [15,1,1,1,4,4,0,0,0];
inference.p_moves = inference.p_moves/sum(inference.p_moves);
inference.p_moves = cumsum(inference.p_moves);
new_max = 0;
 
inference.b_samples = 0;

point_cloud_map = point_cloud;

start_time = cputime;
%% Main Algo
for iter=2:inference.Nmc
    
    %% RJMCMC
    u=rand;
    move = 1;
    while u >  inference.p_moves(move)
       move = move+1;
    end
    
%     if rem(iter,1e2)==0
%         data = sample_z(point_cloud,data);
%     end
    
    md = 0;
    if move == 1
        %% Mark move
        if point_cloud.total_points>0
           [point_cloud,inference,md] = mark_move(data,point_cloud,hyperpriors,inference);
        end
    elseif move == 2
        %% Shift
        if point_cloud.total_points>0
           [point_cloud,inference,md] = shift_move(data,point_cloud,hyperpriors,inference);
        end
    elseif move == 3 
        %% Birth
        [point_cloud,inference,md] = birth_move(data,point_cloud,hyperpriors,inference);
    elseif move == 4
        %% Death
        if point_cloud.total_points > 0 
            [point_cloud,inference,md] = death_move(data,point_cloud,hyperpriors,inference);
        end
    elseif move == 5
        %% Dilate
        if point_cloud.total_points>0
            [point_cloud,inference,md] = dilate_move(data,point_cloud,hyperpriors,inference);
        end
    elseif move == 6
        %% Erode
        if point_cloud.points_with_neigh>0
            [point_cloud,inference,md] = erode_move(data,point_cloud,hyperpriors,inference);
        end
%     elseif move==7
%         %% Split
%         if point_cloud.total_points>0
%              [point_cloud,inference,md] = split_move(data,point_cloud,hyperpriors,inference);
%         end
%     elseif move==8
%         %% Merge
%         if (point_cloud.total_points-point_cloud.PPP{1})>0
%             [point_cloud,inference,md] = merge_move(data,point_cloud,hyperpriors,inference);
%         end
    else
        [point_cloud,inference,md] = sample_ceiling(point_cloud,data,inference,hyperpriors);
    end
    
    map_delta=md;
    if ~isreal(map_delta)
        keyboard;
    end
            
    %% MAP estimation
    log_map(iter) = log_map(iter-1) + map_delta;
    log_lhood(iter) = sum(point_cloud.density);
    if log_map(iter)>inference.max_map && iter>inference.Nbi
        inference.max_map = log_map(iter);
        point_cloud_map = point_cloud;
        new_max = new_max+1;
    end
    
%     if data.L>30 && iter>inference.Nmc/2
%         data.model = 2;
%         for pixel=1:data.L
%             point_cloud.density(pixel) = compute_likelihood(pixel,point_cloud.params{pixel},point_cloud,data);
%         end
%     end
    
    if inference.build_histograms && iter>inference.Nmc*3/4
        inference.p_moves = [1,0,0,0,0,0,0,0,0];
        inference.p_moves = inference.p_moves/sum(inference.p_moves);
        inference.p_moves = cumsum(inference.p_moves);
        inference.histogram(end+1,:) = point_cloud.params{15}(1,:);
    end
    
    %% plot stuff
    if inference.plot_debug && (cputime-start_time)>25 % seconds refresh rate
        start_time = cputime;
        disp('------')
        disp(['complete: ' num2str(round(100*(iter/inference.Nmc))) '%'])
        disp(['new maps: ' num2str(new_max)])
        disp(['total points: ' num2str(point_cloud.total_points)])
        new_max = 0;
        plot_results(point_cloud,data,hyperpriors);
        figure(2)
        title('Maximisation objective')
        plot(log_map(1:iter))
        title('Likelihood objective')
        figure(75)
        plot(log_lhood(1:iter));
        hold off
        figure(3); 
        plot_fit(point_cloud,data,pix_fit);
        
        disp(['moves: ' num2str(inference.canti_moves)])
        move_names = {'birth','death','dilate','erode','shift','reflec', ...
            'height','angle'};
        disp('acc ratio [%]: ')
        for i=1:length(move_names)
            disp([move_names{i} ': ' num2str(100*inference.accepted_moves(i)./inference.canti_moves(i),2) ...
                '%      map_delta: ' num2str(inference.map_delta(i),2)])
        end
        disp(['ceiling height: ' num2str(point_cloud.ceiling.height,2)])
        disp(['ceiling refl: ' num2str(point_cloud.ceiling.refl,2)])
        pause(0.1)
    end
    
end

%% remove low photon points
point_cloud_map = remove_outliers(point_cloud_map,data);

if inference.plot_debug
 figure(3); 
 plot_fit(point_cloud,data,pix_fit);
end

end