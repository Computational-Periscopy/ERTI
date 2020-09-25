function flag = check_inside_prior(t0,pixel,inference)
   flag = sum((t0-inference.T0_prior{pixel})==0); %if the proposal lies inside the prior
end