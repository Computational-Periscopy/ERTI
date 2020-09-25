function config = transform_point(config,data)

if ~isempty(config)
    config(:,1) = config(:,1)*data.params.c*data.params.Tbin/2;
    config(:,2) = fun_r(config(:,2)); % ref 
    config(:,3) = fun_h(config(:,3)); % height
    config(:,4) = fun_alpha(config(:,4));% angle
end

% if verbose
% disp('depths')
% disp(config(:,1))
% 
% disp('reflectivity')
% disp(config(:,2))
% 
% disp('height')
% disp(config(:,3))
% disp('angle')
% disp(config(:,4)/pi*180)
% end
end