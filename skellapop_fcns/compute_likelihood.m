function likelihood = compute_likelihood(pixel,new_config,point_cloud,data)


ceiling = point_cloud.ceiling;

new = get_irf(new_config,ceiling,data)';

if data.model == 2
    likelihood = 0;
    cums = point_cloud.visible;
    for i = 1:data.L
        if i==pixel
            cums = cums + new;
        else
            cums = cums + point_cloud.poisson_density(i,:);
        end
        cums(cums==0) = 1;
        likelihood = likelihood + sum(data.Z(i+1,:).*log(cums)-cums);
    end
else
    %likelihood = -sum(((new-data.z(pixel,:)).^2))/data.rho;
    likelihood = -sum(((new-data.Y(pixel,:)).^2)./(data.Sigma2(pixel,:)));
    %likelihood = -cost(new,data.Y(pixel,:),data.Sigma2(pixel,:),eps);
end
if isnan(likelihood) || ~isreal(likelihood)
    likelihood = -Inf;
    %keyboard;
end


end