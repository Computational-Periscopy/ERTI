function hfig = fcn_plot_layout(sceneNum,point_cloud,plotParams)

%% Ground truth planar facet corners and heights

% Corner points [X,Y,Z]
ceilH = 3.75;
foamH = 8*12*2.54/100;

% Basic 5-sided room Sept. 10, 2019
Cxyz1 = [-1.609,-1.609,1,-0.473,1,1;
    0,2.577,2.577,2.577,1.20,0;
    ceilH*ones(1,3), foamH*ones(1,3)]';
facetPairs1 = [1,2; 2,3; 4,5; 5,6];

% Basic 4-sided room Sept. 11, 2019
Cxyz2 = [-1.709,-1.709,1.042,1.042,1.042;
    0,2.668,2.668,2.668,0;
    ceilH*ones(1,3), foamH*ones(1,2)]';
facetPairs2 = [1,2; 2,3; 4,5];

% Basic 4-sided room Oct. 11, 2019
Cxyz4 = [-1.656,-1.656,0.992,0.992,0.992;
    0,2.757,2.757,2.757,0;
    ceilH*ones(1,3), foamH*ones(1,2)]';
facetPairs4 = [1,2; 2,3; 4,5];

% Basic 4-sided room Oct. 16, 2019
Cxyz5 = [-1.647,-1.647,0.994,0.994,0.994;
    0,2.715,2.715,2.715,0;
    ceilH*ones(1,3), foamH*ones(1,2)]';
facetPairs5 = [1,2; 2,3; 4,5];

switch sceneNum
    case 1
        % Basic room
        Cxyz = Cxyz1;
        facetPairs = facetPairs1;
    case 2
        % Vert. res. test
        Cxyz3 = [-0.930,-0.673,-0.673,-0.417,-0.417,-0.16;
            0.662,0.826,0.826,0.989,0.989,1.153;
            0.3,0.3,0.6,0.6,0.9,0.9]';
        Cxyz = [Cxyz1;Cxyz3];
        
        %         facetPairs3 = [6,7;8,9;10,11];
        facetPairs3 = max(facetPairs1(:))+[1,2;3,4;5,6];
        facetPairs = [facetPairs1;facetPairs3];
    case 3
        % Large planar facet
        Cxyz3 = [-0.6010, 0.386;
            1.236, 1.236;
            1.0, 1.0]';
        Cxyz = [Cxyz1;Cxyz3];
        
        %         facetPairs3 = [6,7];
        facetPairs3 = max(facetPairs1(:))+[1,2];
        facetPairs = [facetPairs1;facetPairs3];
    case 4
        % Mannequin
        Cxyz3 = [-0.349, -0.094;
            1.287, 1.287;
            1.0, 1.0]';
        Cxyz = [Cxyz1;Cxyz3];
        
        %         facetPairs3 = [6,7];
        facetPairs3 = max(facetPairs1(:))+[1,2];
        facetPairs = [facetPairs1;facetPairs3];
        
    case 5
        % Basic room
        Cxyz = Cxyz2;
        facetPairs = facetPairs2;
    case 6
        % Large planar facet
        Cxyz3 = [-0.874, -0.244;
            1.0, 1.8;
            1.0, 1.0]';
        Cxyz = [Cxyz2;Cxyz3];
        
        %         facetPairs3 = [5,6];
        facetPairs3 = max(facetPairs2(:))+[1,2];
        facetPairs = [facetPairs2;facetPairs3];
        
    case 7
        % Two Mannequins
%         Cxyz3 = [ -0.953, -0.726, 0.137,  0.380;
%             1.100,  1.230, 0.936, 0.816;
%             1.0, 1.0, 1.0, 1.0]';
        % Mannequin a
        Cxyz3a = [ -1.013, -0.883, -0.883, -0.796, -0.796, -0.666;
            1.066, 1.14,  1.14, 1.19, 1.19, 1.264;
            0.75, 0.75, 1.02, 1.02, 0.75, 0.75]';
%         Cxyz3b = [0.124, 0.214, 0.214, 0.303, 0.303, 0.393;
%             0.942, 0.898, 0.898, 0.854, 0.854, 0.810;
%             0.66, 0.66, 0.96, 0.96, 0.66, 0.66]';
        Cxyz3b = [0.137,  0.380;
            0.936, 0.816;
            0.96, 0.96]';
        Cxyz = [Cxyz4;Cxyz3a;Cxyz3b];
        
        %         facetPairs3 = [5,6];
%         facetPairs3 = max(facetPairs2(:))+[1,2;3,4];
        facetPairs3 = max(facetPairs2(:))+[1,2;3,4;5,6;7,8];
        facetPairs = [facetPairs4;facetPairs3];
        
    case 8
        % Table + Black Square
        Cxyz3 = [ -0.369, 0.235;
            1.433,  1.433;
            0.75, 0.75]';
        Cxyz = [Cxyz5;Cxyz3];
        
        %         facetPairs3 = [5,6];
        facetPairs3 = max(facetPairs2(:))+[1,2];
        facetPairs = [facetPairs5;facetPairs3];        
end


% Corner points [R,THETA,Z]
Crtz = [sqrt(Cxyz(:,1).^2+Cxyz(:,2).^2),atan2(Cxyz(:,2),Cxyz(:,1)),Cxyz(:,3)];

numFacets = size(facetPairs,1);

Cxyh = cell(numFacets,3);
Crth = cell(numFacets,3);

for ii = 1:numFacets
    Cxyh{ii,1} = [Cxyz(facetPairs(ii,1),1);Cxyz(facetPairs(ii,1),2)];
    Cxyh{ii,2} = [Cxyz(facetPairs(ii,2),1);Cxyz(facetPairs(ii,2),2)];
    Cxyh{ii,3} = Cxyz(facetPairs(ii,1),3);  % Assume height of first coordinate
    
    Crth{ii,1} = [Crtz(facetPairs(ii,1),1);Crtz(facetPairs(ii,1),2)];
    Crth{ii,2} = [Crtz(facetPairs(ii,2),1);Crtz(facetPairs(ii,2),2)];
    Crth{ii,3} = Crtz(facetPairs(ii,1),3);  % Assume height of first coordinate
end

% Angles to sample
numWedges = size(point_cloud.params,1);
numAngles = numWedges + 1;
thetas = linspace(plotParams.thetaOffR,pi-plotParams.thetaOffL,numAngles);

%%
Phi = cell(numWedges,1);
phiCount = 0;
totalPoints = 0;
facetXYs = zeros(1,2);

for ii = 1:numWedges
    for jj = 1:numFacets
        thetajj1 = Crth{jj,1}(2);
        thetajj2 = Crth{jj,2}(2);
        
        [thetaL,maxIdx] = max([thetajj1,thetajj2]); % Left corner
        [thetaR,minIdx] = min([thetajj1,thetajj2]); % Right corner
        
        xyL = Cxyh{jj,maxIdx}(:);
        xyR = Cxyh{jj,minIdx}(:);
        
        %% FIX LOGIC!!
        theta1 = thetas(ii);
        theta2 = thetas(ii+1);
        if  theta1 <= thetaL
            if theta2 >= thetaR
                I = fcn_XY_intersect(xyR,xyL,theta1);
                J = fcn_XY_intersect(xyR,xyL,theta2);
                
                phiCount = phiCount + 1;
                totalPoints = totalPoints + 1;
                minDist = fcn_shortestDist(J,I);
                rotAngle = fcn_RotAngle(J,I);
                refl = 1;
                height = Crth{jj,3};
                Phi{ii}(phiCount,:) = [minDist,refl,height,rotAngle];
                thetaApprox = (theta1+theta2)/2;
                facetXYs(totalPoints,:) = minDist*[cos(thetaApprox), sin(thetaApprox)];
            end
        end
    end
    phiCount = 0;
end

facetMat = cell2mat(Phi);
facetParams.maxDist =  max(4,max(facetMat(:,1)));
facetParams.maxRefl =  max(facetMat(:,2));
facetParams.edgeColor = plotParams.edgeColor;
facetParams.plotColor = plotParams.plotColor;

hfig = figure;
view(-14,64);
for ii = 1:numWedges
    thetaA = thetas(ii);
    thetaB = thetas(ii+1);
    
    for jj = 1:size(Phi{ii},1)
        PhiVect = Phi{ii}(jj,:);
        minDist = PhiVect(1);
        refl = PhiVect(2);
        height = PhiVect(3);
        angle = PhiVect(4);
        fcn_plotPatch3(minDist,height,refl,angle,thetaA,thetaB,facetParams);
    end
end

%% Plot add-ons
xmin = min(facetXYs(:,1));
xmax = max(facetXYs(:,1));
ymax = max(facetXYs(:,2));

if plotParams.show_observer
    hold on;
    observer_cloud = pcread('observer.ply');
    observer_cloud.Intensity = [];
    pcshow(observer_cloud);
end
if plotParams.show_ceiling
    h=patch([xmax,xmin,xmin,xmax],[0,0,ymax,ymax],[ceilH,ceilH,ceilH,ceilH],'b');
    set(h,'facecolor','w','FaceAlpha',plotParams.alpha_ceiling)
end
if plotParams.show_visWall
    h=patch([xmax,xmax,0,0],[0,0,0,0],[ceilH,0,0,ceilH],'b');
    set(h,'facecolor','w','FaceVertexCData',100,'FaceAlpha',plotParams.alpha_visible_wall)
end

view(plotParams.view);
set(gca,'color',plotParams.color_axis,'XColor',plotParams.color_ticks,...
    'YColor',plotParams.color_ticks,'ZColor',plotParams.color_ticks);
set(gcf,'color',plotParams.color_figure);
colormap(plotParams.colormap_t);
axis equal;
caxis([0,2]);
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
    facetColorHSV = [u/facetParams.maxDist, 7/8, 1];
    facetColorRGB = hsv2rgb(facetColorHSV);
    set(h,'facecolor',facetColorRGB,'FaceVertexCData',refl,'linewidth',1,...
        'EdgeColor',facetParams.edgeColor);
else
    set(h,'facecolor','flat','FaceVertexCData',refl,'linewidth',1,...
        'EdgeColor',facetParams.edgeColor);
end
end

