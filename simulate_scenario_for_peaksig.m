%% Simulates room/objects response.
%% Charles Saunders @ Boston University

addpath('D:\GoogleDrive\Active Corner Camera')

%% Global parameters
c = 299792458; %Speed of light

% Measurement histogram timing resolution
bin_size =  0.016*10^-9; %In seconds
distance_resolution = bin_size*c; %(in m) 5 cm resolution

laser_pulse_width = 1*10^-9; %0.1 ns

laser_intensity = 1000; %arbitrary - just stops final values going too small


%% Scene parameters
wall_direction_vector = [1,0,0]; % Just for reference
corner_position = [0,0]; % Just for reference

FOV_center = [0.1,-0.05, 0]; %SPAD FOV
FOV_radius = 0.02;

laser_angles = linspace(pi/2+0.1,3*pi/2-0.1,45); %pi/4 is left -> 3*pi/4 right
laser_distance = 0.015; %Distance from corner
laser_pos = [laser_distance*sin(laser_angles'),laser_distance*cos(laser_angles'),zeros(length(laser_angles),1)];

% Smaller = finer resolution
wall_discr = distance_resolution*0.5; %resolution in m
params.FOV_center = FOV_center;
params.FOV_radius = FOV_radius;
params.wall_discr = wall_discr;
params.bin_size = bin_size;
params.laser_intensity = laser_intensity;
params.c = c;
params.laser_pulse_width = laser_pulse_width;

%% Scene objects
clear objects;

room_leftwall = - 1.042;
room_rightwall = 1.709;
room_topwall = 2.668;
room_ceiling = 3.75;

objects{1,1} = 'wall';
objects{1,2} = [room_leftwall, 0, 0]; %Corner
objects{1,3} = [0, room_topwall, 0]; %Vector spanning wall, 1
objects{1,4} = [0, 0, room_ceiling]; %Vector spanning wall, 2
objects{1,5} = [1,0,0]; %Normal vector

objects{end+1,1} = 'wall';
objects{end,2} = [room_leftwall,room_topwall, 0]; %Corner
objects{end,3} = [room_rightwall-room_leftwall, 0, 0]; %Vector spanning wall, 1
objects{end,4} = [0, 0, room_ceiling]; %Vector spanning wall, 2
objects{end,5} = [0,-1,0]; %Normal vector

objects{end+1,1} = 'wall';
objects{end,2} = [room_rightwall, room_topwall, 0]; %Corner
objects{end,3} = [0, -room_topwall, 0]; %Vector spanning wall, 1
objects{end,4} = [0, 0, room_ceiling]; %Vector spanning wall, 2
objects{end,5} = [-1,0,0]; %Normal vector

% Ceiling
objects{end+1,1} = 'wall';
objects{end,2} = [room_leftwall, room_topwall, room_ceiling]; %Corner
objects{end,3} = [0, -room_topwall, 0]; %Vector spanning wall, 1
objects{end,4} = [room_rightwall-room_leftwall, 0, 0]; %Vector spanning wall, 2
objects{end,5} = [0,0,-1]; %Normal vector

%% Simulate measurement
tic
measurement = simulate_measurement(laser_pos,objects,params);
toc

%%

% figure()
% plot(measurement)
% title('Measurement')
% 
% figure()
% dmeas = -diff(measurement,1,2);
% for i = 1:size(dmeas,2)-6
%     subplot(size(dmeas,2)-6,1,i)
% plot(dmeas(:,i))
% end
% title('Derivative signals')
measurement = fliplr(measurement);

d.params.Tbin = bin_size*4; %params.bin_size;% Bin resolution in seconds
d.params.numBins = length(measurement);     % Length of measurement vector
d.params.c = physconst('LightSpeed');  % Speed of light (m/s)
d.params.angleWidth = 2*pi/size(measurement,2);

load('phi.mat')
Phi = flipud(Phi);

    addpath('skellypop_fcns');
    
    

%%
correct_surface(1:6,1:20) = 0;
correct_height(1:6,1:20) = 0;
correct_angle(1:6,1:20) = 0;

tollist_ang = linspace(1,45,20).*(pi/180);
tollist = linspace(0.025,0.25,20);
tollist_h = linspace(0.025,0.5,20);
SPlist = [100,75, 25, 15, 5,1];

for SP = 1:length(SPlist)
count = 0;
scaling = SPlist(SP)/( sum(measurement(:))./length(measurement(:)));

for trials = 1:25
    noisy_meas = poissrnd(measurement.*scaling + ones(length(measurement),1)*scaling*(sum(measurement(:))/(length(measurement(:))*100)));
    Y = noisy_meas';
    binRes = bin_size;
    save(['data\' 'current_test.mat'],'Y','binRes');
    
    % This script runs the skellypop algorithm
    % if you wish to modify the hyperparameters,
    % open the script get_hyperparameters.m
    fig = 10; % figure where results are plotted
    plot_debug = true; % boolean enabling intermediate plotting of the MCMC estimation 

    %% choose a dataset from the data folder
    filename = 'current_test'; %'2019_09_10_erti_nlos_3_Histograms_20';

    %% choose number of MCMC iterations
    iterations = 2e3; % more iterations might provide better (and slower) estimation

    est = run_dataset(filename,iterations,0,fig);
    %%
    for i = 1:length(est.params)
        config = transform_point(est.params{i},d);
        if ~isempty(config)
        for jj = 1:length(tollist)
            if abs(config(1) - Phi{i}(1)) < tollist(jj)
                correct_surface(SP,jj) = correct_surface(SP,jj) + 1;
            end
            if abs(config(3) - Phi{i}(3)) < tollist_h(jj)
                correct_height(SP,jj) = correct_height(SP,jj) + 1;
            end
            if abs(abs(config(4)) - abs(Phi{i}(4))) < tollist_ang(jj)
                correct_angle(SP,jj) = correct_angle(SP,jj) + 1;
            end
        end
        end
        count = count + 1;
    end
end
end

%%
subplot(1,3,1)
for i = 1:6
    plot(tollist,100*correct_surface(i,:)/count)
    hold on
end
legend('100','75', '25', '15', '5','1')
xlabel('Tolerance (m)')
ylabel('% facets correct within tolerance')
grid on

subplot(1,3,2)
for i = 1:6
    plot(tollist_h,100*correct_height(i,:)/count)
    hold on
end
legend('100','75', '25', '15', '5','1')
xlabel('Tolerance (m)')
ylabel('% facets correct within tolerance')
ylim([0,100])
grid on

subplot(1,3,3)
for i = 1:6
    plot(tollist_ang.*(180/pi),100*correct_angle(i,:)/count)
    hold on
end
legend('100','75', '25', '15', '5','1')
xlabel('Tolerance (degrees)')
ylabel('% facets correct within tolerance')
grid on