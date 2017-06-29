# Bitwise-CA-Opeartions
Code repository for the paper Bitwise Operations of Cellular Automaton on Gray Scale Images published at [Irish Signals and Systems Conference](http://www.issc.ie/site/view/7/) in June 2017.

All of the code is written independent of 3rd person libraries in MATLAB 2016 with plots and data crunching in Python27.

The specific folders have corresponding readme.txt for instructions. Refer to the paper for exact details on algorithm and implementation 

[ArXiv link](https://arxiv.org/abs/1705.07080) for the paper. 

## Abstract:

Cellular Automata (CA) theory is a discrete model that represents the state of each of its cells from a finite set of possible values which evolve in time according to a pre-defined set of transition rules. CA have been applied to a number of image processing tasks such as Convex Hull Detection, Image Denoising etc. but mostly under the limitation of restricting the input to binary images. In general, a gray-scale image may be converted to a number of different binary images which are finally recombined after CA operations on each of them individually. We have developed a multinomial regression based weighed summation method to recombine binary images for better performance of CA based Image Processing algorithms. The recombination algorithm is tested for the specific case of denoising Salt and Pepper Noise to test against standard benchmark algorithms such as the Median Filter for various images and noise levels. The results indicate several interesting invariances in the application of the CA, such as the particular noise realization and the choice of sub-sampling of pixels to determine recombination weights. Additionally, it appears that simpler algorithms for weight optimization which seek local minima work as effectively as those that seek global minima such as Simulated Annealing.

## Different models used and How to Run:
1.Frequency Based Approach : It is a very naive way to use weights decided empirically for each thresholded image based on the number of pixel intensity values in a small range around it.

2. Specific Median Filtering : A slightly modified version of the already in-buit functionality in MATLAB for comparing our result against.

## Situations Evaluated:

Three Rules denoising at 0.1 Salt and Pepper Noise Level : 
