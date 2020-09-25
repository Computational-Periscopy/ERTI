function figHandle = fcn_plot_erti_data(point_cloud,data,plotParams)

% Step 1: Transform SkellaPoP output to model parameters
numWedges = size(point_cloud.params,1);
numAngles = numWedges + 1;
if plotParams.flip_x
    thetas = linspace(plotParams.thetaOffR,pi-plotParams.thetaOffL,numAngles);
else
    thetas = pi-linspace(plotParams.thetaOffR,pi-plotParams.thetaOffL,numAngles);
end

facetCell = cell(numWedges,1);
numFacets = 0;

for ii = 1:numWedges
    numCellFacets = size(point_cloud.params{ii},1);
    facetCell{ii} = zeros(numCellFacets,6);
    for jj = 1:numCellFacets
        numFacets = numFacets + 1;
        PhiVect = transform_point2(point_cloud.params{ii}(jj,:),data);
        facetCell{ii}(jj,1) = PhiVect(1); %minDist
        facetCell{ii}(jj,2) = PhiVect(2);  % refl
        facetCell{ii}(jj,3) = PhiVect(3); % height
        facetCell{ii}(jj,4) = PhiVect(4);  % angle
        facetCell{ii}(jj,5) = thetas(ii);
        facetCell{ii}(jj,6) = thetas(ii+1);
    end
end

facetAngles = zeros(numFacets,1);

%% Plot Facets
facetMat = cell2mat(facetCell);
facetParams.maxDist =  max(4,max(facetMat(:,1)));
facetParams.maxRefl =  max(facetMat(:,2));
facetParams.edgeColor = plotParams.edgeColor;
facetParams.plotColor = plotParams.plotColor;
facetParams.caxis = plotParams.caxis;

close(figure(10))
figHandle = figure(10);

numPoints = 2*plotParams.numNeighbors+1;
deltas = [-plotParams.numNeighbors:-1,1:plotParams.numNeighbors];
facetNum = 0;
numFitAngles = 0;
facetXYs = zeros(1,2);

for ii = 1:numWedges
    for jj = 1:size(facetCell{ii},1)
        % For each facet in each wedge...
        
        facetNum = facetNum + 1;
        thisFacet = facetCell{ii}(jj,:);
        
        % Approximate facet location can be determined by taking the middle
        % angle of the wedge and the minimum distance to the wedge, then
        % compute cartesian coordinates
        rApprox = thisFacet(1);
        thetaApprox = (thisFacet(5)+thisFacet(6))/2;
        thisFacetXY = rApprox*[cos(thetaApprox), sin(thetaApprox)];
        facetXYs(facetNum,:) = thisFacetXY;
        
        % To determine angle based on linear fit with neighbors
        if plotParams.numNeighbors
            neighborNum = 1;    % if 1, then no neighboring points
            points = zeros(numPoints,2);
            pointOrder = zeros(numPoints,1);
            points(neighborNum,:) = thisFacetXY;
            
            % For selected neighborhood size, look for other approximate
            % facet locations within distance tolerance distTol
            for kk = deltas
                pix_n = ii+kk;
                if pix_n>0 && pix_n<=numWedges
                    if ~isempty(point_cloud.params{pix_n})
                        dataCell = facetCell{pix_n};
                        for ll = 1:size(dataCell,1)
                            % Compute approximate Cartesian coordinates for
                            % potential neighbors
                            rApprox = facetCell{pix_n}(ll,1);
                            thetaApprox = (facetCell{pix_n}(ll,5)+facetCell{pix_n}(ll,6))/2;
                            XYapprox = rApprox*[cos(thetaApprox), sin(thetaApprox)];
                            if norm(points(1,:)-XYapprox) <= plotParams.distTol
                                % if neighboring facet, add to list of
                                % points
                                neighborNum = neighborNum+1;
                                points(neighborNum,:) = XYapprox;
                                pointOrder(neighborNum) = kk;
                            end
                        end
                    end
                end
            end
            
            % If a facet has at least one neighbor, compute a linear fit of
            % their approximate locations
            if neighborNum>1
                p = polyfit(points(1:neighborNum,1),points(1:neighborNum,2),1);
                
                % Compute the slope of the linear fit within that wedge:
                % computes point of intersection between linear fit and
                % Left and Right theta angles on either side of wedge.
                % If distance from origin (i.e., norm) of left intersection
                % point is greater than norm of right point, then rotation
                % angle should be positive in our model. 
                thetaL = max(thisFacet(5:6));
                thetaR = min(thisFacet(5:6));
                
                intL = [p(2)/(tan(thetaL)-p(1));p(2)*tan(thetaL)/(tan(thetaL)-p(1))];
                intR = [p(2)/(tan(thetaR)-p(1));p(2)*tan(thetaR)/(tan(thetaR)-p(1))];
                
                % If linear fit would indicate positive rotation angle, set
                % rotation angle sign to (+) if estimated angle is
                % reasonably close, or set angle to fit angle if difference
                % is greater than angular tolerance
                if norm(intL) > norm(intR)
                    intL2 = norm(intR)*[cos(thetaL);sin(thetaL)];
                    V1 = intL-intR;
                    V2 = intL2 - intR;
                    linFitAngle = acos(V2'*V1/(norm(V1)*norm(V2)));
                    facetEstAngle = thisFacet(4);
                    
                    if abs(linFitAngle-facetEstAngle)<plotParams.angleTol
                        facetAngles(facetNum) = facetEstAngle;
                    else
                        facetAngles(facetNum) = linFitAngle;
                        numFitAngles = numFitAngles +1;
                    end
                else
                    % Likewise if linear fit would indicate negative 
                    % rotation angle, set sign to (-) to fit angle 
                    intR2 = norm(intL)*[cos(thetaR);sin(thetaR)];
                    V1 = intR-intL;
                    V2 = intR2 - intL;
                    linFitAngle = acos(V2'*V1/(norm(V1)*norm(V2)));
                    facetEstAngle = thisFacet(4);
                    
                    if abs(linFitAngle-facetEstAngle)<plotParams.angleTol
                        facetAngles(facetNum) = -facetEstAngle;
                    else
                        facetAngles(facetNum) = linFitAngle;
                        numFitAngles = numFitAngles +1;
                    end
                end
            else
                facetAngles(facetNum) = thisFacet(4);
            end
        else
            facetAngles(facetNum) = thisFacet(4);
        end
        fcn_plotPatch3(thisFacet(1),thisFacet(3),...
            thisFacet(2),facetAngles(facetNum),...
            thisFacet(5),thisFacet(6),facetParams)
    end
end

%% Plot add-ons
xmin = min(facetXYs(:,1));
xmax = max(facetXYs(:,1));
ymax = max(facetXYs(:,2));
ceiling_height = point_cloud.ceiling.height;

if plotParams.show_observer
    hold on
    pcshow(pcread('observer.ply'));
end
if plotParams.show_ceiling
    h=patch([xmax,xmin,xmin,xmax],[0,0,ymax,ymax],[ceiling_height,ceiling_height,ceiling_height,ceiling_height],'b');
    set(h,'facecolor','w','FaceAlpha',plotParams.alpha_ceiling)
end
if plotParams.show_visWall
    if plotParams.flip_x
        h=patch([xmin,xmin,0,0],[0,0,0,0],[ceiling_height,0,0,ceiling_height],'b');
    else
        h=patch([xmax,xmax,0,0],[0,0,0,0],[ceiling_height,0,0,ceiling_height],'b');
    end
    set(h,'facecolor','flat','FaceVertexCData',100,'FaceAlpha',plotParams.alpha_visible_wall)
end

view(plotParams.view);
set(gcf,'color',plotParams.color_figure);
set(gca,'color',plotParams.color_axis,'XColor',plotParams.color_ticks,...
    'YColor',plotParams.color_ticks,'ZColor',plotParams.color_ticks);
if plotParams.show_grid
    grid on;
    set(gca,'gridcolor','w','GridLineStyle','--');
end
colormap(plotParams.colormap_t);
axis equal;
caxis(plotParams.caxis)

end

function fcn_plotPatch3(u,height,refl,phi,thetaA,thetaB,facetParams)
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

Xs = [C1(1),C2(1),C2(1),C1(1)];
Ys = [C1(2),C2(2),C2(2),C1(2)];
Zs = height*[0 0 1 1];

h=patch(Xs,Ys,Zs,'b');

if facetParams.plotColor
    reflVal = min(refl/facetParams.caxis(2),1);
    facetColorHSV = [u/facetParams.maxDist, 1, reflVal];
    facetColorRGB = hsv2rgb(facetColorHSV);
    set(h,'facecolor',facetColorRGB,'FaceVertexCData',refl,'linewidth',1,...
        'EdgeColor',facetParams.edgeColor);
else
    set(h,'facecolor','flat','FaceVertexCData',refl,'linewidth',1,...
        'EdgeColor',facetParams.edgeColor);
end

end

