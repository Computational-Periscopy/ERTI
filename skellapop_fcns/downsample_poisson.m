function data = downsample_poisson(data,factor)


if factor>1
   
    L=ceil(data.L/factor);
    
    X = zeros(L,size(data.Y,2));
    
    k=1; 
    for i=1:L
        idx = 1+(i-1)*factor:min([i*factor,data.L]);
        X(k,:) = sum(data.Y(idx,:),1);
        k = k+1;
    end
    
    data.Y = X;
    data.L = L;
end

end