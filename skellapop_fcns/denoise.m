function x = denoise(Y)

lambda = 500;
Y = Y';
h = [1,-1];
d = zeros(size(Y));
d(1:length(h)) = h;
d = circshift(d,-2);
H = fft(d);
H = lambda*abs(H).^2;
mu = log(mean(Y));

g = @(B) -Y+exp(B+mu)+ifft(H.*fft(B),'symmetric');
tol = 1e-2;  maxit = 100;
B = log(Y+1);

dH = 1./(H+1e-5);
Precond = @(x) ifft(dH.*fft(x),'symmetric');

for i=1:maxit
    grad = g(B);
    
    gg = grad'*grad;
    if gg/length(B)<0.1
        break
    end
    
%% Hessian update
    [~,c] = compute_taylor(B,mu,Y);
    Q_fun = @(x) (ifft(H.*fft(x),'symmetric')+c.*x); 
    [B_delta,~] = pcg(Q_fun,grad,tol,maxit,Precond);
    
    B = B - B_delta;
    
end

x = exp(B+mu);
if sum(isnan(B))
    keyboard
end

end