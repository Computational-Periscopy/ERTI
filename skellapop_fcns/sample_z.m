function data = sample_z(point_cloud,data)


x = point_cloud.poisson_density;

A  = @(x) forw_op(x,1);
AT = @(x)forw_op(x,2);


eta1 = data.Y+randn(size(x)).*sqrt(data.Y2);
eta2 = x+randn(size(x)).*sqrt(data.rho);

z = AT(A(eta1)./data.Y2)+eta2/data.rho;

z = z(:);
[L,T] = size(x);
Q_fun = @(z) reshape(AT(A(reshape(z,L,T))./data.Y2),L*T,1)+z/data.rho;
tol = 1e-2;  maxit = 1000;
[z_new,~] = pcg(Q_fun,z,tol,maxit);

data.z = reshape(z_new,L,T);


end