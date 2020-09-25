function inference=modify_prior(inference,hyperpriors,pixel,old_config,new_config)

p = inference.T0_prior{pixel};

counter = 0;
for i=1:size(old_config,1)
    counter=counter -length(p(p>=old_config(i,1)-hyperpriors.max_dist & p<=old_config(i,1)+hyperpriors.max_dist));
end

for i=1:size(new_config,1)
    counter=counter + length(p(p>=new_config(i,1)-hyperpriors.max_dist & p<=new_config(i,1)+hyperpriors.max_dist));
end

inference.eff_prior_length=inference.eff_prior_length-counter;

end


