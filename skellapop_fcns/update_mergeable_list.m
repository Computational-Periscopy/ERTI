function   Mergeable_pixels = update_mergeable_list(t0_prop,t0,max_dist,pixel,Mergeable_pixels)

count = 0;
for j=1:length(t0)
    for i=j+1:length(t0)
       if abs(t0(j)-t0(i))<=max_dist
           count = count+1;
       end
    end
end


new_count = 0;
for j=1:length(t0_prop)
    for i=j+1:length(t0_prop)
       if abs(t0_prop(j)-t0_prop(i))<=max_dist
           new_count = new_count+1;
       end
    end
end

if new_count ~= count
    if count
        m=Mergeable_pixels{count};
        m(m==pixel)=[];
        Mergeable_pixels{count}=m;
    end
    if new_count
        Mergeable_pixels{new_count}=[Mergeable_pixels{new_count};pixel];
    end
end


end