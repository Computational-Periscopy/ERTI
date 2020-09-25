function point_cloud = fill_occupied_volume(point_cloud,data,hyperpriors)

point_cloud.occupied_volume=zeros(data.L,data.T);

for n=1:data.L
    a=max([n-1,1]):min([n+1,data.L]);
    if ~isempty(point_cloud.params{n})
        t0=point_cloud.params{n}(:,1);
        for k=1:length(t0)
            t0_new=t0(k);
            b=t0_new-hyperpriors.Nbin:t0_new+hyperpriors.Nbin;
            point_cloud.occupied_volume(a,b)=point_cloud.occupied_volume(a,b)+1;
        end
    end
end


end