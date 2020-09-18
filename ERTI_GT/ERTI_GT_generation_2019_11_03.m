%% ERTI Ground Truth Generation Test
% Joshua Rapp
% Boston University
% September 24, 2019

clear; close all; clc;

% Parameters
sceneNum = 2;
numAngles = 45; % Angles to sample

%% Ground truth planar facet corners and heights
% List in Cxyz x,y positions of corners + heights, then list in facetPairs
% which corners are connected

% Corner points [X,Y,Z]
ceilH = 3.75;
foamH = ceilH; 8*12*2.54/100;

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
        
        facetPairs3 = max(facetPairs1(:))+[1,2];
        facetPairs = [facetPairs1;facetPairs3];
    case 4
        % Mannequin
        Cxyz3 = [-0.349, -0.094;
            1.287, 1.287;
            1.0, 1.0]';
        Cxyz = [Cxyz1;Cxyz3];
        
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
        
        facetPairs3 = max(facetPairs2(:))+[1,2];
        facetPairs = [facetPairs2;facetPairs3];
end

%% Converts Corner points [R,THETA,Z]
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

numWedges = numAngles-1;
thetas = linspace(0,pi,numAngles);

%% Determine which facets are present at each wedge
Phi = cell(numWedges,1);
phiCount = 0;
totalPoints = 0;
for ii = 1:numWedges
    for jj = 1:numFacets
        thetajj1 = Crth{jj,1}(2);
        thetajj2 = Crth{jj,2}(2);
        
        [thetaL,maxIdx] = max([thetajj1,thetajj2]); % Left corner
        [thetaR,minIdx] = min([thetajj1,thetajj2]); % Right corner
        
        xyL = Cxyh{jj,maxIdx}(:);
        xyR = Cxyh{jj,minIdx}(:);
       
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
                
            end
        end
    end
    phiCount = 0;
end

%% Plot GT as facets
color_figure = 'k'; % r/b/k/w etc
color_axis = 'k';% r/b/k/w etc
color_ticks = 'w';% r/b/k/w etc
colormap_t = gray(100);
flip = false;
figure;
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
        fcn_plotPatch(minDist,angle,height,refl,thetaA,thetaB,flip);
    end
end
set(gcf,'color',color_figure);
set(gca,'color',color_axis,'XColor',color_ticks,'YColor',color_ticks,'ZColor',color_ticks);
colormap(colormap_t);
axis equal;