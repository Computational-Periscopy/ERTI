function log_prize = area_interaction(data,point_cloud,pixel,new_config,hyperpriors)

prize = 0;
old_config = point_cloud.params{pixel};



diff = zeros(1,data.T);

%% prev config
for i=1:size(old_config,1)
    c=max([1,old_config(i,1)-hyperpriors.Nbin]):min([data.T,old_config(i,1)+hyperpriors.Nbin]);
    diff(c) = diff(c) + 1; 
end

%% new config
for i=1:size(new_config,1)
    c=max([1,new_config(i,1)-hyperpriors.Nbin]):min([data.T,new_config(i,1)+hyperpriors.Nbin]);
    diff(c) = diff(c) - 1; 
end

a=max([pixel-1,1]):min([pixel+1,data.L]);

ind = (diff<0);
prize = -sum(sum(point_cloud.occupied_volume(a,ind)==0));

ind = (diff>0);
prize = prize + sum(sum(point_cloud.occupied_volume(a,ind)==1));

%% penalties
prize=prize/(hyperpriors.Nbin*2+1);
delta_points = (size(new_config,1)-size(old_config,1));
log_prize= prize*hyperpriors.log_gamma_area_int+delta_points*hyperpriors.lambda_area_int;