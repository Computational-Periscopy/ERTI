function [pixel,index] = choose_random_point(point_cloud)

    u=rand*point_cloud.total_points;
    list=0; csum=0;
    while(u>csum)
        list=list+1;
        csum=csum+point_cloud.sum_PPP(list)*list;
    end
    
    list_pixel=randi(point_cloud.sum_PPP(list));
    p=point_cloud.PPP{list};
    pixel=p(list_pixel);
    
    index=randi(list);
end