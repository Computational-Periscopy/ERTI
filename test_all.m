clear all; close all; clc;
%% Run multiple datasets

%% choose days
days = {'2019_09_11';'2019_09_10'};

%% choose dwell times 
acq_times = [60,30,20,10];

%% choose hidden scenes
scenes = 1:6;

%% choose MCMC iterations
iterations = 2e3;

%% find dataset files
filenames = [];
for i=1:length(days)
    for j=1:length(acq_times)
        for k=1:length(scenes)
            filename = [days{i} '_erti_nlos_' num2str(scenes(k)) '_Histograms_' num2str(acq_times(j))];
            if isfile(['data\' filename '.mat'])
                filenames{end+1} = filename;
            end
        end
    end
end

%% run algo
plot_debug = false;
fig = 1;
for i=1:length(filenames)
    disp(['--------------  Running dataset ' num2str(i) ' out of ' num2str(length(filenames)) ' ---------------'])
    run_dataset(filenames{i},iterations,plot_debug,fig);
    savefig(['results\' filenames{i} '.fig'])
end

