function log_dens = gamma_pdf(u,k,theta)

log_dens = (k-1)*log(u)-u/theta-gammaln(k)-k*log(theta);
end