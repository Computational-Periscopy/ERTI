function pdf = gauss_pdf(val,sigma)

pdf = sum(-log(2*pi)/2-log(sigma)-(val./sigma).^2/2);


end