function [B_new,map_delta] = sample_one_B(B,point_cloud,hyperpriors,data)


B_new = zeros(data.L,1);
map_delta = 0;

dens = zeros(data.T,1);
%% sample pixels
phots = 0 ;
for l=1:data.L
    dens = dens + point_cloud.density(l,:)';
    phots = phots + sample_photon_sum(data.Y(l,:)',dens,B);
end

B_new = gamrnd(phots+hyperpriors.a,1/(1/hyperpriors.b+data.L*data.T));
dens = zeros(data.T,1);
for l=1:data.L
    dens = dens + point_cloud.density(l,:)';
    map_delta = map_delta + data.Y(l,:)*(log(dens+B_new)-log(dens+B));
end


map_delta = map_delta - (B_new-B)*data.L*data.T;

prior = (hyperpriors.a-1)*(log(B_new)-log(B))-(B_new-B)/hyperpriors.b;
map_delta = map_delta + prior;

%% sample hyperprior
%hyperprior.b = 1./gamrnd(1.sum(B));

if isnan(map_delta) || ~isreal(map_delta)
    keyboard
end

end