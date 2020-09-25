function I = fcn_XY_intersect(R,L,thetaI)

A = [cos(thetaI);sin(thetaI)];
u = R-L;
sI = (A(2)*L(1)-A(1)*L(2))/(u(2)*A(1)-u(1)*A(2));
I = L+sI*(R-L);

end

