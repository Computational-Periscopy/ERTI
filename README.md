## SkellyPoP algorithm (MATLAB)

**Paper title:** 
"ERTI"

**Authors:**
J. Rapp, C. Saunders, J. Tachella, J. Murray-Bruce, Y. Altmann, J-Y. Tourneret, S. McLaughlin, R. Dawson, F. Wong and V. K. Goyal

**Published in:**
(...)

**Link to pdf:**
(...)

## How to run this demo
1. Download the files in this repository
2. Check minimal requirements (below)
3. Run test.m

Optionally, multiple datasets can be 

If another dataset is desired, just uncomment the desired dataset in run_example

## Trying the code with your data
Add to the folder 'data' a my_data.mat file containing:
1. A array Y (double) containing the Lidar histograms of size(Y) = [L, T] where L is the number of wedges and T is the number of histogram bins.
3. A scalar BinRes (double) containing the TCSPC binning resolution in seconds.

Run the script convert_file.m, selecting the file my_data.mat

## Tuning the hyperparameters

Change the following variables in the get_hyperparam.m script.

### Facet hyperparameters

reflectivity_std = 1; % Standard deviation of reflectivity facets. Smaller values mean more spatial smoothing. Reasonable interval [0.5,5]

angle_std = 1; % Standard deviation of reflectivity facets. Smaller values mean more spatial smoothing. Reasonable interval [0.5,5]

height_std = 0.8; % Standard deviation of reflectivity facets. Smaller values mean more spatial smoothing. Reasonable interval [0.5,5]

facet_number = (data.L)/8; % Controls the number of facets. Smaller values mean more spatial smoothing. It should scale with the number of sensed wedges. Reasonable interval [1,5]

position_smoothing = 4; % Controls the amount of smoothing of facets' positions. Reasonable interval [1,5]}

min_dist = 0.35; % Minimum distance between two facets in the same wedge in metres. Smaller values might generate more spurious facets, whereas larger values might miss some facets.

### Ceiling hyperparameters

ceiling_height_k = 10; % Shape parameter of the a priori ceiling's height. Check Gamma Distribution Wikipedia

celiing_height_theta =  1;  % Scale parameter of the a priori ceiling's height. Check Gamma Distribution Wikipedia

ceiling_reflectivity_k = 2; % Shape parameter of the a priori ceiling's reflectivity. Check Gamma Distribution Wikipedia

celiing_reflectivity_theta = 1;  % Scale parameter of the a priori ceiling's reflectivity. Check Gamma Distribution Wikipedia


## Dataset naming (data folder)

"yyyy_mm_dd_erti_nlos_(scene number)_Histograms_(dwell time).mat"

## Requirements
MATLAB 2018a (other releases have not been tested)


