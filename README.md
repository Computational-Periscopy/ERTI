## SkellyPoP algorithm (MATLAB)

**Paper title:** 
Seeing Around Corners with Edge-Resolved Transient Imaging

**Authors:**
J. Rapp, C. Saunders, J. Tachella, J. Murray-Bruce, Y. Altmann, J-Y. Tourneret, S. McLaughlin, R. Dawson, F. Wong and V. K. Goyal

**Published in:**
(to be updated soon)

**Link to pdf:**
(to be updated soon)

## How to run this demo
1. Download the files in this repository
2. Check minimal requirements (below)
3. Run run_example.m
4. Choose the desired dataset in run_example.m

## Trying the code with your data
Add to the folder 'data' a my_data.mat file containing:
1. A array Y (double) containing the Lidar histograms of size(Y) = [L, T] where L is the number of wedges and T is the number of histogram bins.
3. A scalar BinRes (double) containing the TCSPC binning resolution in seconds.

Run the script convert_file.m, selecting the file my_data.mat

## Tuning the hyperparameters
Change the following variables in the get_hyperparam.m script.

## Requirements
MATLAB 2019b (other releases have not been tested)