function [point_cloud,data,inference] = backprojection(data)

data.scale = 1;
noceil.maxDepth = data.T*data.params.c*data.params.Tbin/2;
noceil.refl = 0;
noceil.height = 3;
atten = (1:data.T).^2;

%% find ceiling
noceil.refl = 1;
hc = get_irf([],noceil,data);
ind = find(hc>max(hc)*0.01,1);
hc = circshift(hc,-ind+1);
sy = sum(data.Y,1);
ccorr = ifft(conj(fft(hc,2*data.T)).*fft(sy',2*data.T),'symmetric');
ccorr = ccorr(1:data.T);
[~,ind] = max(ccorr.*atten');
noceil.height = ind*data.params.c*data.params.Tbin/2;

hc = get_irf([],noceil,data);
hc = hc/sqrt(hc'*hc);
alpha = sy*hc;

disp(['Ceiling at ' num2str(noceil.height) ' m']);

%% backproj
noceil.refl = 0;
point = [round(data.T/2),log(1),log(4),inv_fun_alpha(.1)];
h = get_irf(point,noceil,data);

h = fliplr(h);
d = find(h>1e-3*max(h),1);
h = circshift(h,-d);

h_norm = h'*h;
h = fft(h,2*data.T);

y = zeros(data.L,data.T);

X = fft((data.Y-ones(data.L,1)*(hc*alpha/data.L)')./sqrt(data.Sigma2),2*data.T,2);

for i=1:data.L
     d = ifft(h'.*(X(i,:)),'symmetric');
     y(i,:) = d(1:data.T);
end
thres = max(y(:))*0.06; 
prior = y>thres;
prior(:,ind:end) = 0;
%figure(40)
%imagesc(prior)
%pause(0.1)

%% find correct reflectivity scale
X = fft(data.Y,2*data.T,2);
for i=1:data.L
    d =  ifft(h'.*(X(i,:)),'symmetric');
     y(i,:) = d(1:data.T);
end

data.scale =  mean(y(prior))/h_norm/5;


inference.T0_prior = cell(data.L,1);
for i=1:data.L
   inference.T0_prior{i} = find(prior(i,:));
end


noceil.refl = 1;
hc = get_irf([],noceil,data);
alpha = sy*hc/data.L/(hc'*hc);
noceil.refl = alpha;

point_cloud.params = cell(data.L,1);
point_cloud.density = zeros(data.L,1);
point_cloud.ceiling = noceil;



end