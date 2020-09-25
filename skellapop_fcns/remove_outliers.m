function point_cloud = remove_outliers(point_cloud,data)

%% trim height

new_params = point_cloud.params;

for pixel=1:length(point_cloud.params)
    
   
    if ~isempty(point_cloud.params{pixel})
        
        out = zeros(size(point_cloud.params{pixel},1),1);
        
        config = transform_point(point_cloud.params{pixel},data);
        
        data.params.occlusion = true;
        for j=1:size(config,1)
            point_cloud.params{pixel}(j,3) = inv_fun_h(min([point_cloud.ceiling.height,config(j,3)]));
            
            r_config = point_cloud.params{pixel};
            r_config(j,:) = [];
            
            likelihood = compute_likelihood(pixel,r_config,point_cloud,data);
            
            delta = (point_cloud.density(pixel)-likelihood)/abs(point_cloud.density(pixel))*100;
            
            if data.model==2
            out(j) = delta<0.1;
            else
            out(j) = delta<0.1;
            end
        end
        out = out | (config(:,3)<0.2) | config(:,2)>40;
        new_params{pixel} = point_cloud.params{pixel}(~out,:);
    end
end
 point_cloud.params = new_params;

end