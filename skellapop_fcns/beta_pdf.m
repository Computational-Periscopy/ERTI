function log_dens = beta_pdf(u,b1,b2)

log_dens = (b1-1)*log(u)+(b2-1)*log(1-u)-betaln(b1,b2);

end