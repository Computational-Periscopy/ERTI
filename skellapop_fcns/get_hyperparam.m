function hyperpriors = get_hyperparam(data)

%% Facet hyperparameters
reflectivity_std = 1.5; % Standard deviation of reflectivity facets. Smaller values mean more spatial smoothing. Reasonable interval [0.5,5]
angle_std = 1; % Standard deviation of reflectivity facets. Smaller values mean more spatial smoothing. Reasonable interval [0.5,5]
height_std = 1.5; % Standard deviation of height facets. Smaller values mean more spatial smoothing. Reasonable interval [0.5,5]
facet_number = (data.L)/8; % Controls the number of facets. Smaller values mean more spatial smoothing. It should scale with the number of sensed wedges. Reasonable interval [(data.L)/16,(data.L)/6]
position_smoothing = 2; % Controls the amount of smoothing of facets' positions. Reasonable interval [1,5]
min_dist = 0.4; % Minimum distance between two facets in the same wedge in metres. Smaller values might generate more spurious facets, whereas larger values might miss some facets.

%% Ceiling hyperparameters
ceiling_height_k = 10; % Shape parameter of the a priori ceiling's height. Check Gamma Distribution Wikipedia
celiing_height_theta =  1;  % Scale parameter of the a priori ceiling's height. Check Gamma Distribution Wikipedia
ceiling_reflectivity_k = 2; % Shape parameter of the a priori ceiling's reflectivity. Check Gamma Distribution Wikipedia
celiing_reflectivity_theta = 1;  % Scale parameter of the a priori ceiling's reflectivity. Check Gamma Distribution Wikipedia

%% automatic setting (I don't recommend touching this)
hyperpriors.alpha = [(reflectivity_std)^2,(angle_std)^2,(height_std)^2];
hyperpriors.beta = [hyperpriors.alpha(1),hyperpriors.alpha(2),hyperpriors.alpha(3)];
hyperpriors.lambda_S = 1;
hyperpriors.log_gamma_area_int = position_smoothing;
hyperpriors.lambda_area_int = facet_number;

hyperpriors.Nbin = round(min_dist/data.params.c/data.params.Tbin*2)-1;

hyperpriors.k_rceil = ceiling_reflectivity_k;
hyperpriors.theta_rceil = celiing_reflectivity_theta;

hyperpriors.k_hceil = ceiling_height_k;
hyperpriors.theta_hceil = celiing_height_theta;

end