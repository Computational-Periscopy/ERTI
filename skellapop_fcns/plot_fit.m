function  plot_fit(point_cloud,data,pixels)


for i=1:length(pixels)
    subplot(5,ceil(length(pixels)/5),i)
    pixel = pixels(i);
    h = get_irf(point_cloud.params{pixel},point_cloud.ceiling,data);
    hold off
    plot(data.Y(pixel,:))
    hold on
    plot(h)
    title(['wedge ' num2str(i)])
end

end