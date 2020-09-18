clear all; close all; clc; 
%%
% This script runs the skellypop algorithm
% if you wish to modify the hyperparameters,
% open the script get_hyperparameters.m

fig = 10; % figure where results are plotted
plot_debug = true; % boolean enabling intermediate plotting of the MCMC estimation 

%% choose a dataset from the data folder
filename = '2019_10_11_erti_nlos_1_Histograms_30'; %'2019_09_10_erti_nlos_3_Histograms_20';

%% choose number of MCMC iterations
iterations = 2e3; % more iterations might provide better (and slower) estimation

addpath('skellypop_fcns');

run_dataset(filename,iterations,plot_debug,fig);