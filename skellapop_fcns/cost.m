function c = cost(mu,y,sigma2,epsilon) % Skellam negative log likelihood
    c = nansum(sigma2 -(y./2).*(log(sigma2+(mu+epsilon)) - log(max(eps,sigma2-(mu+epsilon)))) - log_besseli(y,sqrt( max(0,sigma2.^2 - (mu+epsilon).^2)))) ;
end


function val= log_besseli(n,x)  % log(Iy(x))
    val = log(besseli(n,x,1)) +x;
    v=find(val == -Inf);
    val(v) = n(v).*log(0.5*x(v)) + log((x(v).^2./(256*(n(v)+1))).*(x(v).^2./(n(v)+4)).*(x(v).^2./(n(v)+3)).*(x(v).^2./(n(v)+2)) + (x(v).^3./(64*(n(v)+1).*(n(v)+2))).*(x(v).^3./(n(v)+3)) + (x(v).^2./(16*(n(v)+1))).*(x(v).^2./(n(v)+2)) + x(v).^2./(4*(n(v)+1)) +1) - (log(n(v)+1) + n(v).*log(n(v)) -n(v));
    val(val == Inf) = x(val == Inf) + log(-4*n(val == Inf).^2+8*x(val == Inf)+1) - log(16*sqrt(pi)*x(val == Inf).^(3/2));
end

function val= besseli_diff(n,x) % Iy-1(x) + Iy+1(x) / Iy(x)
     val = exp(log_besseli(n-1,x) - log_besseli(n,x)) + exp(log_besseli(n+1,x) - log_besseli(n,x)); 
end
