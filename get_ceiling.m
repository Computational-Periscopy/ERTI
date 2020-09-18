function [height] = get_ceiling(data)

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
height = ind*data.params.c*data.params.Tbin/2;


end