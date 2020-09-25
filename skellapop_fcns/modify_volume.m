function point_cloud = modify_volume(pixel,new_config,point_cloud,hyperpriors,data)


old_config = point_cloud.params{pixel};


prev = 0;
%% get neighbors
for iter=-1:1
    pix_n = pixel+iter;
    if pix_n>0 && pix_n<=data.L
        for index = 1:size(point_cloud.params{pix_n},1)
            t0 = point_cloud.params{pix_n}(index,1);
            prev = prev +  (point_cloud.occupied_volume(pix_n,t0)>1);
        end
    end
end

a=max([pixel-1,1]):min([pixel+1,data.L]);
%% prev config
for i=1:size(old_config,1)
    c=max([1,old_config(i,1)-hyperpriors.Nbin]):min([data.T,old_config(i,1)+hyperpriors.Nbin]);
    point_cloud.occupied_volume(a,c) = point_cloud.occupied_volume(a,c)-1;
end

%% new config
for i=1:size(new_config,1)
    c=max([1,new_config(i,1)-hyperpriors.Nbin]):min([data.T,new_config(i,1)+hyperpriors.Nbin]);
    point_cloud.occupied_volume(a,c) = point_cloud.occupied_volume(a,c)+1;
end


new = 0;
%% get neighbors
for iter=-1:1
    pix_n = pixel+iter;
    if pix_n>0 && pix_n<=data.L
        if iter==0
            if ~isempty(new_config)
                t0 = new_config(:,1);
            else
                t0 = [];
            end
        else
            if ~isempty(point_cloud.params{pix_n})
                t0 = point_cloud.params{pix_n}(:,1);
            else
                t0 = [];
            end
        end
        for index = 1:length(t0)
            new = new +  (point_cloud.occupied_volume(pix_n,t0(index))>1);
            point_cloud.neigh{pix_n}(index) = (point_cloud.occupied_volume(pix_n,t0(index))-1);
        end
    end
end

point_cloud.points_with_neigh = point_cloud.points_with_neigh+new-prev;

end



    
