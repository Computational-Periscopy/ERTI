function [point_cloud]=find_all_neighbors(point_cloud,L)

point_cloud.neigh = cell(L,1);
point_cloud.neigh_sum = zeros(2,1);

for l=1:L
    
    if ~isempty(point_cloud.params{l})
        t0 = point_cloud.params{l}(:,1);
        
        neigh = zeros(size(t0));
        for i=1:length(t0)
            neigh(i) = point_cloud.occupied_volume(l,t0(i))-1;
            if neigh(i)
                if neigh(i)>2
                    keyboard
                end
                point_cloud.neigh_sum(neigh(i))= point_cloud.neigh_sum(neigh(i))+1;
            end
        end
        point_cloud.neigh{l}=neigh;
    else
        point_cloud.neigh{l}=0;
    end
end

point_cloud.points_with_neigh = sum(point_cloud.neigh_sum);

end