function fcn_plotPatch(u,phi,height,refl,thetaA,thetaB,flip)
%FCN_PLOTPATCH
%   u := distance to nearest point on facet
%   phi := rotation angle of facet from closest corner
%   thetaA := first angle in wedge
%   thetaB := second angle in wedge

%   Assume 0 <= theta1 < theta2 <= pi
theta1 = min(thetaA,thetaB);
theta2 = max(thetaA,thetaB);

% half-wedge width
gamma = (theta2- theta1)/2;
magPhi = abs(phi);

if phi > 0  % theta1 corner of facet is closer
    if magPhi > gamma
        w1 = u;
    else
        w1 = u/cos(gamma-magPhi);
    end
    alpha = magPhi + pi/2 - gamma;
    beta = pi - 2*gamma - alpha;
    w2 = w1*sin(alpha)/sin(beta);
    
else
    if magPhi > gamma
        w2 = u;
    else
        w2 = u/cos(gamma-magPhi);
    end
    alpha = magPhi + pi/2 - gamma;
    beta = pi - 2*gamma - alpha;
    w1 = w2*sin(alpha)/sin(beta);
end

C1 =[w1*cos(theta1); w1*sin(theta1)];
C2 =[w2*cos(theta2); w2*sin(theta2)];

if flip
    flipX = -1;
else
    flipX = 1;
end

Xs = flipX*[C1(1),C2(1),C2(1),C1(1)];
Ys = [C1(2),C2(2),C2(2),C1(2)];
Zs = height*[0 0 1 1];

h=patch(Xs,Ys,Zs,'b');
set(h,'facecolor','flat','FaceVertexCData',refl,'EdgeColor','w');

end

