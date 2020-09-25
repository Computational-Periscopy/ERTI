function  [prec,mean_a,det_term]=get_GP_par(t0_new,pixel,point_cloud,data,hyperpriors,mark_move)


neighs = 2;
a_neigh = zeros(neighs,3);
delta = [-1,1];
k = 0;
%% get neighbors
for iter=1:neighs
    pix_n = pixel+delta(iter);
    if pix_n>0 && pix_n<=data.L
        if ~isempty(point_cloud.params{pix_n})
            t0 = point_cloud.params{pix_n}(:,1);
            a = point_cloud.params{pix_n}(:,2:end);
            for j=1:length(t0)
                if abs(t0(j)-t0_new) <= 2*hyperpriors.Nbin
                    k = k+1;
                    a_neigh(k,:) = a(j,:);
                end
            end
        end
    end
end
a_neigh = a_neigh(1:k,:);

%% precision matrix
if k==0
    prec = hyperpriors.beta./hyperpriors.alpha;
    mean_a = zeros(1,3);
    det_term = 1/2*sum(log(prec)-log(2*pi));
else
    p = -1*ones(k,1); % rho = 1; % the AR process has a closed form for log(||P||/||P_old||)
    pp = hyperpriors.beta - sum(p);
    
    prec = pp./hyperpriors.alpha;
    mean_a = (-sum(a_neigh.*p,1))./pp;
    
    det_term = 0;
    if mark_move == false
        for j=1:length(hyperpriors.alpha)
            det_delta = log(sqrt(hyperpriors.beta(j)*(hyperpriors.beta(j) + 4)) + hyperpriors.beta(j) + 2) - log(2);
            det_term = det_term + 1/2*(det_delta - log(hyperpriors.alpha(j)) - log(2*pi)) - 1/2*(sum(a_neigh(:,j).^2.*(-p)) - pp(j)*mean_a(:,j).^2)/hyperpriors.alpha(j);
        end
    end
end
end