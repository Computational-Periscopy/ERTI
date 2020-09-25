function scatterbar3(X,Y,ref,Z,width,angle,ceiling_height,ceiling_ref)

%% facet plotter @ Julián tachella 2019 
% Inputs X: vector of x positions of the facets (in metres)
%        Y: vector of y positions of the facets (in metres)
%        Z: vector of heights of the facets (in metres)
%        ref: vector with reflectivity of the facets (in unnormalized units)
%        angle: vector with angles of the facets (in radians)
%        ceiling_height: scalar with the height of the ceiling (in metres)
%        ceiling_ref: scalar with the reflectivity of the ceiling (in unnormalized units)

%% settings
color_figure = 'k'; % r/b/k/w etc
color_axis = 'k';% r/b/k/w etc
color_ticks = 'w';% r/b/k/w etc
colormap_t = gray(100); %copper(100); % parula(100), jet(100), etc.
colormap_scale = 'lin'; % lin/log
show_observer = false; % true/false
alpha_visible_wall = 0.7; % [0,1]
alpha_ceiling = 0.5; % [0,1]


%%
%ref = ref/max(ref);
r=size(Z,1);
for j=1:r
    if ~isnan(Z(j))
        drawbar(X(j),Y(j),Z(j),width(j),ref(j),angle(j))
    end
end

xmax = max(X);
xmin = min(X);

ymax = max(Y);

%% occluder
h=patch([xmax,xmax,0,0],[0,0,0,0],[ceiling_height,0,0,ceiling_height],'b');
set(h,'facecolor','flat','FaceVertexCData',100,'FaceAlpha',alpha_visible_wall)

%% ceiling
h=patch([xmax,xmin,xmin,xmax],[0,0,ymax,ymax],[ceiling_height,ceiling_height,ceiling_height,ceiling_height],'b');
set(h,'facecolor','flat','FaceVertexCData',ceiling_ref,'FaceAlpha',alpha_ceiling)

%% human
if show_observer
    hold on
    pcshow(pcread('data/observer.ply'));
end
set(gcf,'color',color_figure);
set(gca,'color',color_axis,'XColor',color_ticks,'YColor',color_ticks,'ZColor',color_ticks);
colormap(colormap_t);
set(gca,'colorscale',colormap_scale)
%% limits
axis image
%colorbar
axis([min(X(:))-max(width) max(X(:))+max(width)+1 -1 max(Y(:))+max(width) zlim])
caxis([0,5])
%caxis([min(ref(:)) min([max(ref(:)),10])])
%zlim([0,ceiling_height+0.5])

function drawbar(x,y,z,width,ref,angle)

rot = [cos(angle),-sin(angle);sin(angle),cos(angle)];

vert = [-width/2,width/2,width/2,-width/2;0,0,0,0];

vert = rot*vert+[x;y];

heights = z*[0,0,1,1];

h=patch(vert(1,:),vert(2,:),heights,'b');
set(h,'facecolor','flat','FaceVertexCData',ref,'EdgeColor','none')
