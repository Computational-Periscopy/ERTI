%% Simulates room/objects response.
%% Charles Saunders @ Boston University
% May 2019
close all; clear all;

%% Global parameters
c = 299792458; %Speed of light

% Measurement histogram timing resolution
bin_size =  0.016*10^-9; %In seconds
distance_resolution = bin_size*c; %(in m) 5 cm resolution

laser_pulse_width = 1*10^-9; %0.1 ns

laser_intensity = 1000; %arbritrary - just stops final values going too small


%% Scene parameters
wall_direction_vector = [1,0,0]; % Just for reference
corner_position = [0,0]; % Just for reference

FOV_center = [0.2,-0.1, 0]; %SPAD FOV
FOV_radius = 0.05;

laser_angles = linspace(pi/2+0.1,3*pi/2-0.1,37); %pi/4 is left -> 3*pi/4 right
laser_distance = 0.03; %Distance from corner
laser_pos = [laser_distance*sin(laser_angles'),laser_distance*cos(laser_angles'),zeros(length(laser_angles),1)];

% Smaller = finer resolution
wall_discr = distance_resolution*4; %resolution in m
cyl_discr = distance_resolution*4; %Resolution in m

params.FOV_center = FOV_center;
params.FOV_radius = FOV_radius;
params.wall_discr = wall_discr;
params.cyl_discr = cyl_discr;
params.bin_size = bin_size;
params.laser_intensity = laser_intensity;
params.c = c;
params.laser_pulse_width = laser_pulse_width;

%% Scene objects
clear objects;

room_leftwall = - 3;
room_rightwall = 2;
room_topwall = 4;
room_ceiling = 5;
cyl_height = 1.75;
cyl_radius = 0.22;

%% walls
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

%% Ceiling
objects{end+1,1} = 'wall';
objects{end,2} = [room_leftwall, room_topwall, room_ceiling]; %Corner
objects{end,3} = [0, -room_topwall, 0]; %Vector spanning wall, 1
objects{end,4} = [room_rightwall-room_leftwall, 0, 0]; %Vector spanning wall, 2
objects{end,5} = [0,0,-1]; %Normal vector

% objects{end+1,1} = 'cylinder';
% objects{end,2} = [-3,2]; %Position
% objects{end,3} = cyl_radius; %Radius
% objects{end,4} = cyl_height+randn()*0.5; %Height
% 
% objects{end+1,1} = 'cylinder';
% objects{end,2} = [0.5,6]; %Position
% objects{end,3} = cyl_radius; %Radius
% objects{end,4} = cyl_height+randn()*0.5; %Height
% 
% objects{end+1,1} = 'cylinder';
% objects{end,2} = [3,4]; %Position
% objects{end,3} = cyl_radius; %Radius
% objects{end,4} = cyl_height+randn()*0.5; %Height

%% Simulate measurement
tic
measurement = simulate_measurement(laser_pos,objects,params);
toc

%%

figure()
plot(measurement)
title('Measurement')

figure()
dmeas = -diff(measurement,1,2);
for i = 1:size(dmeas,2)-6
    subplot(size(dmeas,2)-6,1,i)
plot(dmeas(:,i))
end
title('Derivative signals')

Y = measurement(1:4000,:);
Y = fliplr(Y)';

[L,T] = size(Y);
%% generate data
phots = 10*L*T;
sbr = 10;

b = phots*1/(sbr+1)/(L*T);
s = phots*1/(1/sbr+1)*Y;

Y = poissrnd(s+b);

figure()
plot(Y(20,:)-Y(19,:))

save('room_with_ceiling_phot10.mat','Y','params');

