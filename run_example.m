clear all; close all; clc; 
%%
% "Seeing Around Corners with Edge-Resolved Transient Imaging"
%
% Joshua Rapp, Charles Saunders, Julian Tachella, John Murray-Bruce,
% Yoann Altmann, Jean-Yves Tourneret, Stephen McLaughlin,
% Robin M. A. Dawson, Franco N. C. Wong & Vivek K Goyal
%
% Nature Communications
% Contact: julian.tachella@ed.ac.uk


%% Choose a dataset to process
% Hidden scene name. Options below:
% Real data: 'mannequin', 'mannequins', 'empty_room',
% 'big_empty_room', 'board', 'staircase'
% Synthetic data: 'synthetic_verticalT', 'synthetic_farT_cylinder', 
% 'synthetic_farT', 'synthetic_empty_room', 'synthetic_cylinder'

scene = 'staircase';

% Acquisition time in seconds. Only for real data.
% Options: 10,20,30 and 60.
acq_time = 30; 

%% Run Skellapop algorithm
plot_debug = false; % boolean enabling intermediate plotting of the MCMC estimation 
MCMC_iterations = 3e3; % number of MCMC iterations
% other hyperparameters can be tuned in get_hyperparam.m

addpath('skellapop_fcns');

if contains(scene, 'synthetic')
    filename = scene;
else
    filename = [scene '_' num2str(acq_time) 's'];
end

skellapop(filename, MCMC_iterations, plot_debug);