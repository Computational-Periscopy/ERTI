function [u,c] = compute_taylor(B,mu,Y)


c = exp(B+mu);
u = Y-exp(B+mu) + c.*B;

end