function [pixel,index] = choose_merge_point(point_cloud)


    s_PPP=sum(point_cloud.sum_PPP(2:end).*(1:length(point_cloud.sum_PPP(2:end)))');
    u=rand*s_PPP;
    list=1; csum=0;
    while(u>csum)
        list=list+1;
        csum=csum+point_cloud.sum_PPP(list)*list;
    end
    
    list_pixel=randi(point_cloud.sum_PPP(list));
    p=point_cloud.PPP{list};
    pixel=p(list_pixel);
    
    index=randi(list);
end