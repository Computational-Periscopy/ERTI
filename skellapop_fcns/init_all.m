function [point_cloud] = init_all(point_cloud,data,inference,hyperpriors)

%% init A, B and T0, PPP and make sure prior is respected
if isempty(point_cloud)
    point_cloud.params = cell(data.L,1);
    point_cloud.density = zeros(data.L,1);
    ceiling.refl = 1;
    ceiling.height = 3;
    ceiling.maxDepth = data.T*data.params.c*data.params.Tbin/2;
    point_cloud.ceiling = ceiling;
else
    for pixel=1:data.L
        inference = modify_prior(inference,hyperpriors,pixel,[],point_cloud.params{pixel});
    end
end

if data.model == 2
point_cloud = estimate_visible(data,point_cloud);
end
point_cloud.poisson_density = zeros(size(data.Y));
for pixel=1:data.L
    point_cloud.poisson_density(pixel,:) = get_irf(point_cloud.params{pixel},point_cloud.ceiling,data)';
end

for pixel=1:data.L
    point_cloud.density(pixel) = compute_likelihood(pixel,point_cloud.params{pixel},point_cloud,data);
end

point_cloud.PPP = cell(inference.max_ppp,1);

point_cloud.total_points = sum(cellfun(@(x) size(x,1),point_cloud.params));
point_cloud = fill_occupied_volume(point_cloud,data,hyperpriors);
point_cloud = find_all_neighbors(point_cloud,data.L);

for l=1:data.L
    pp = size(point_cloud.params{l},1);
    if pp>0
        point_cloud.PPP{pp} = [point_cloud.PPP{pp};l];
    end
end
point_cloud.sum_PPP = cellfun(@length,point_cloud.PPP);

end