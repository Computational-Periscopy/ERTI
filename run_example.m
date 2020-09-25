clear all; close all; clc; 
%%
% "Seeing Around Corners with Edge-Resolved Transient Imaging"
%
% Joshua Rapp, Charles Saunders, Julián Tachella, John Murray-Bruce,
% Yoann Altmann, Jean-Yves Tourneret, Stephen McLaughlin,
% Robin M. A. Dawson, Franco N. C. Wong & Vivek K Goyal
%
% Nature Communications


%% Choose a dataset to process
% Hidden scene name. Options: 'mannequin', 'mannequins', 'empty_room',
% 'big_empty_room', 'board', 'staircase'
scene = 'staircase';

% Acquisition time in seconds. Options: 10,20,30 and 60.
acq_time = 30; 

%% Run Skellapop algorithm
plot_debug = false; % boolean enabling intermediate plotting of the MCMC estimation 
MCMC_iterations = 3e3; % number of MCMC iterations
% other hyperparameters can be tuned in get_hyperparam.m

addpath('skellypop_fcns');
filename = [scene '_' num2str(acq_time) 's'];
skellapop(filename, MCMC_iterations, plot_debug);