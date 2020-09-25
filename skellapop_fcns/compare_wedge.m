function [hit,fals,h_hit,angle_hit] = compare_wedge(data,gt_config,config,max_dist,max_dist_h)

config = transform_point(config,data);
gt_config = transform_point(gt_config,data);
gt_config(:,1) = gt_config(:,1)/4;
hit = 0;
used = zeros(size(config,1),1);
h_hit = 0;
angle_hit = 0;

for i=1:size(gt_config,1)
    
    for j=1:size(config,1)
        if used(j)==0 && abs(gt_config(i,1)-config(j,1))<max_dist
            used(j) = 1;
            hit = hit+1;
            if abs(gt_config(i,3)-config(j,3))<max_dist_h
                h_hit = h_hit + 1;
            end
            
            if abs(gt_config(i,4)-config(j,4))<pi/6 % 30 degrees
                angle_hit = angle_hit + 1;
            end
            break;
        end
    end
end

%h_err = h_err/size(gt_config,1);
fals = sum(used==0);

end