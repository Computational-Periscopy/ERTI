function [new_point_cloud,new_inference] = upsample_pointcloud(point_cloud,inference,hyperpriors,data)

    L = length(point_cloud.params);
    newL = data.L;
    
    new_point_cloud.params = cell(newL,1);
    new_point_cloud.total_points = cell(newL,1);
    new_inference = inference;
    new_inference.T0_prior = cell(newL,1);
    
    for n=1:L
        old_params = point_cloud.params{n};
        params = old_params;
        new_point_cloud.params{2*(n-1)+1} = params;
        new_inference.T0_prior{2*(n-1)+1} = inference.T0_prior{n};
        %% second extension
        if n<L
            old_params_neigh = point_cloud.params{n+1};
            for j=1:size(old_params,1)
                for p=1:size(old_params_neigh,1)
                    if abs(old_params(j,1)-old_params_neigh(p,1))<=2*hyperpriors.Nbin
                        params(j,1) = round((old_params(j,1)+old_params_neigh(p,1))/2);
                        params(j,2:3) = log(exp(old_params(j,2:3))+exp(old_params_neigh(p,2:3)))-log(2);
                        params(j,4) = inv_fun_alpha((fun_alpha(old_params(j,4))+fun_alpha(old_params_neigh(p,4)))/2);
                        break;
                    end
                end
            end
        end
        new_point_cloud.params{2*(n-1)+2} = params;
        new_inference.T0_prior{2*(n-1)+2} = inference.T0_prior{n};
    end
    
    
    for n=(2*L+1):newL
        new_inference.T0_prior{n} = new_inference.T0_prior{2*L};
        new_point_cloud.params{n} = new_point_cloud.params{2*L};
    end
    
    for n=1:newL
        params = new_point_cloud.params{n};
        flag_keep = ones(size(params,1),1,'logical');
        for j=1:size(params,1)
            for p=j+1:size(params,1)
                if abs(params(j,1)-params(p,1))<=2*hyperpriors.Nbin
                    flag_keep(p) = false;
                end
            end
        end
        new_point_cloud.params{n} = params(flag_keep,:);
    end
    new_point_cloud.ceiling = point_cloud.ceiling;
    new_point_cloud.total_points = sum(cellfun(@(x) size(x,1),new_point_cloud.params));

end