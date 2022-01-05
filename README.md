Introduction:
This project contains the model to solve the MILP problems presented in publication
https://www.sciencedirect.com/science/article/pii/S0306261917315337#f0015

the MILP problems are formulated in MATLAB (R2016B) using the YALMIP toolbox, and solved using IBM ILOG CPLEX Optimization Studio 

Contents:
Each of the folders contain the script used for the respective scenario
Initially, I created seperate instances of each script to generate results per set of 10 households (variables FirstHID to LastHID)

This was done in order to counter performance issues encounter with the CPLEX solver at the time.
So for each model, 4 seperate scripts were used to handle 10 households each
The file workspacecomplier.m was used to compile the results back together, resulting in one complete file per scenario (e.g. S2CES_COMPLETE.mat)

In this publication, i've reduced it to one script per scenario model instead of the 4 instances of the same script I used in the project. 
This was done to avoid having anymore duplicated code then needed.

The resulting files from workspacecompiler.m, can be further compiled by tables.m into tablematerial_ALL.mat
tablematerial_ALL.mat is a large compilation of the results of every scenario into one .mat file. to make it easier to work with.

The LCOE and PBP for the economic performance tables are calculated using economics.m, which gets its data from tablematerial_ALL.mat and from a file names relshare.mat, which contained the share in the CES for each household

Note from the author:
These scripts were my first introduction to MATLAB and programming in general. Please keep that in mind when reading through it :). 
