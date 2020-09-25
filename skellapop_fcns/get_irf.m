function h = get_irf(config,ceiling,data)


config = transform_point(config,data);
h = genMeas3(config,ceiling,data.params)*data.scale;


%h = ifft(fft(h).*data.IRF,'symmetric');

h(h<0) = 0;

end