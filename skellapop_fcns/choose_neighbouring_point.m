function [pixel,t0_new] = choose_neighbouring_point(point_cloud,hyperpriors)

    L = size(point_cloud.occupied_volume,1);
    accepted=false;
    iter = 1;
    while ~accepted && iter<200
        iter = iter+1;
        [center_pixel,index] = choose_random_point(point_cloud);
        neigh = point_cloud.neigh{center_pixel}(index);
        if neigh < (2-((center_pixel==1)||(center_pixel==L)))
             accepted=true;
        end
    end
    
    if iter<200
        %% pick a neighboring pixel
        %%pick a bin
        t0_center_pix = point_cloud.params{center_pixel}(index,1);


        order=randperm(2);
        flag=true; p=1;

        nn = [-1,1];
        while flag %% 
            if p>2
                keyboard
            end
            pixel = center_pixel+nn(order(p));

            if pixel>0 && pixel<=L
                flag=false;
                if ~isempty(point_cloud.params{pixel})
                    t0 = point_cloud.params{pixel}(:,1);
                    for j=1:length(t0)
                        if abs(t0_center_pix-t0(j))<=hyperpriors.Nbin
                            flag=true;
                            break
                        end
                    end
                end
            end
            p=p+1;
        end

        t0_new=randi([t0_center_pix-hyperpriors.Nbin,t0_center_pix+hyperpriors.Nbin]);
    
    else
       pixel = 0;
       t0_new = 0;
    end
    
end