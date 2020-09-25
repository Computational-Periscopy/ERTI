function plot_results(point_cloud,data,hyperpriors)


if point_cloud.total_points>1
    %% Plots
    % Plot Acq Data
    
    plotParams.thetaOffR = 0;
    plotParams.color_figure = 'w';
    plotParams.color_axis = 'k';
    plotParams.color_ticks = 'k';
    plotParams.show_grid = false;
    plotParams.edgeColor = 0.2*ones(1,3);
    plotParams.colormap_t = gray(100);
    plotParams.distTol = 0.35;
    plotParams.angleTol = pi/5;
    plotParams.thetaOffL = pi/20;
    plotParams.numNeighbors = 2;
    plotParams.view = [20,15];
    plotParams.caxis = [0,5];
    plotParams.colormap_scale = 'lin';
    plotParams.show_ceiling = true;
    plotParams.show_visWall = true;
    plotParams.alpha_visible_wall = 0.2;
    plotParams.alpha_ceiling = 0.2;
    plotParams.plotColor = false;
    plotParams.flip_x = false;

    plotParams.show_observer = false;
    fcn_plot_erti_data(point_cloud,data,plotParams);
    figSizeAcq = [500, 170, 400, 520]; set(gcf, 'Position', figSizeAcq);
    ylim([-.75,3.2]); xlim([-2,1.6]); view([15, 40]);
    ylh = ylabel('m'); ylh.Position(2) = ylh.Position(2) + 1;
    xlabel('m'); zlabel('m'); set(gca,'fontsize',22);
end

end