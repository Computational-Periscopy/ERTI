function config = transform_point2(config,data)

if ~isempty(config)
    config(:,1) = config(:,1)*data.params.c*data.params.Tbin/2;
    config(:,2) = fun_r(config(:,2)); % ref 
    config(:,3) = fun_h(config(:,3)); % height
    config(:,4) = fun_alpha(config(:,4));% angle
end

end

function r = fun_r(r_tilde)
 r = exp(r_tilde+1);
end

function h = fun_h(h_tilde)
 h = exp(h_tilde+.5);
end

function alpha = fun_alpha(alpha_tilde)

alpha = (pi/3)./(1+exp(-(alpha_tilde-1)));

end
