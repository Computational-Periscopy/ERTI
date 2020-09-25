function  [point_cloud,inference] = change_point(pixel,new_config,point_cloud,inference,hyperpriors,data,likelihood,mark_flag)

prev_len = size(point_cloud.params{pixel},1);

new_len = size(new_config,1);

if prev_len~=new_len
    if prev_len>0 %remove pixel from list of length(a) points
        p=point_cloud.PPP{prev_len};
        p(p==pixel)=[];point_cloud.PPP{prev_len}=p;
        point_cloud.sum_PPP(prev_len)=point_cloud.sum_PPP(prev_len)-1;
    end
    
    if new_len>0
        point_cloud.PPP{new_len}=[point_cloud.PPP{new_len};pixel];
        point_cloud.sum_PPP(new_len)=point_cloud.sum_PPP(new_len)+1;
    end
    
    point_cloud.total_points = point_cloud.total_points + (new_len-prev_len);
end

if ~mark_flag
    point_cloud = modify_volume(pixel,new_config,point_cloud,hyperpriors,data);
    inference = modify_prior(inference,hyperpriors,pixel,point_cloud.params{pixel},new_config);
end


% if sum(exp(new_config(:,3))>100)
%     keyboard
% end
point_cloud.params{pixel} = new_config;

point_cloud.poisson_density(pixel,:) = get_irf(point_cloud.params{pixel},point_cloud.ceiling,data)';
if data.model == 2
    for jj = 1:data.L
point_cloud.density(jj) = likelihood;
    end
else
point_cloud.density(pixel) = likelihood;
end

end