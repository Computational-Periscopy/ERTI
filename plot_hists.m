% '2019_10_16_erti_nlos_1_Histograms_60'

for i = 1:15
    subplot(5,3,i)
    plot((0:length(histData)-1)*16/1000,histData(:,1+(i-1)*3))
    title(['Position: ', num2str(1+(i-1)*3)])%,'   Approx HVR: ',num2str(round(mean(histData(:,1+(i-1)*3)-histData(:,1))/mean(histData(:,1)),2))])
    xlim([0,50])
    if (mod(i,3)==1)
        ylabel('Counts')
    end
    if (i>12)
        xlabel('Time (ns)')
    end
end

% histDiff = diff(histData,1,2);
figure()
for i = 1:15
    subplot(5,3,i)
    plot((0:length(histData)-1)*16/1000,histData(:,1+(i-1)*3 + 1) - histData(:,1+(i-1)*3))
    title(['Wedge ',num2str(1+(i-1)*3), '  SCR: ',num2str(round(sum(histData(:,1+(i-1)*3 + 1) - histData(:,1+(i-1)*3))./sum(histData(:,1+(i-1)*3)),4))])
    xlim([0,50])
    if (mod(i,3)==1)
        ylabel('Counts')
    end
    if (i>12)
        xlabel('Time (ns)')
    end
end
