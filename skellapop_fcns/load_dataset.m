function data = load_dataset(filename,downsampling)

    load(['data\' filename])
    
    %% In case the data was named histData instead of Y
    if ~exist('Y','var')
       Y = histData';
    end
    
    
    if prod(downsampling)>1
        
        Y_old = Y;
        Y = zeros(floor(size(Y,1)/downsampling(1)),floor(size(Y,2)/downsampling(2)));
        
        for i=1:size(Y,1)
            for t=1:size(Y,2)
                idx = 1+(i-1)*downsampling(1):min([i*downsampling(1),size(Y_old,1)]);
                Y(i,t) = sum(sum(Y_old(idx,1+(t-1)*downsampling(2):t*downsampling(2))),2);
            end
        end
        
        
    end
    
    if downsampling(1)==1
        data.model = 1;
    else
        data.model = 1;
    end
        
    %ind = sum(Y,1)>0;
    %Y = Y(:,ind);
    %Y = Y(:,1:end-10);
    data.L = size(Y,1)-1;
    data.T = size(Y,2);
    
    
    
    data.Y = zeros(data.L,data.T);
    
    data.params.Tbin = binRes*downsampling(2); %params.bin_size;% Bin resolution in seconds
    data.params.numBins = data.T;     % Length of measurement vector
    data.params.c = physconst('LightSpeed');  % Speed of light (m/s)
    data.params.angleWidth = 2*pi/data.L;
    data.params.occlusion = true;
    %% Denoising
    data.Sigma2 = zeros(data.L,data.T);
    
%     lambda1 = denoise(Y(1,:));
%     data.Sigma2(1,:) = lambda1;
%     for l=1:data.L
%         lambda2 = denoise(Y(l+1,:));
%         data.Sigma2(l,:) = lambda2+lambda1;
%         lambda1 = lambda2;
%     end

    
 %  data.SigmaY2 = Y(2:end,:);
   %data.Z = Y;
   % data.Y2 = Y(2:end,:);
    for l=data.L:-1:1
   %     data.Y2(l,:) = data.Y2(l,:) - Y(1,:);
        data.Y(l,:) = Y(l+1,:)-Y(l,:);
        data.Sigma2(l,:) = Y(l+1,:)+Y(l,:);
    end
   data.Sigma2(data.Sigma2<=0) = 1;
   %data.SigmaY2(data.SigmaY2<=0) = 1;
   %data.Y2(data.Y2<=0) = 10;
    
    %% check if first wedge is faulty and replace
    if sum(data.Y(1,:))>2*sum(data.Y(2,:))
        data.Y(1,:) = data.Y(2,:);
        data.Sigma2(1,:) = data.Sigma2(2,:);
    end
    
  %  data.rho = 10;
    
    t = (1:data.T)';
    sigma = 10/downsampling(2);%(params.laser_pulse_width/params.bin_size)/downsampling/2;
    h = exp(-(t/sigma).^2/2)/sqrt(2*pi)/sigma;
    data.IRF = fft(h);
    
  % data.z = data.Y;

end