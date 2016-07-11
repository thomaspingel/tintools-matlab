# tintools-matlab
Create a Triangular Irregular Network (TIN) from a Digital Elevation Model (DEM)

Several tools for the creation of Triangular Irregular Networks (TINs) from Digital Elevation Models (DEMs). This tool uses Chen and Guevara's (1987) Very Important Points (VIP) algorithm to create the TIN.

TIN creation takes two steps. First, the points from the raster are selected using vipmask.m. Then, this (or any other) mask is used to create the TIN with dem2tin.m. The performance of the algorithm can be evaluated with verifytin.m. 


Sample code: 

% Create image 

ZI = peaks(40); 

% Create a referencing matrix 

R = [0 1; 1 0; 0 0]; 

% Select VIP points 

ZImask = vipmask(ZI,.6,true); 

% Create the TIN from the image, refmat, and mask 

[tri x y z] = dem2tin(ZI,R,ZImask); 

% Check error 

[ZIe ZIn] = verifytin(ZI,R,x,y,z); 


Chen, Z. & Guevara, J.A. (1987). Systematic Selection of Very Important Points (VIP) From Digital Terrain Model for Constructing Triangular Irregular Networks. In Proceedings, AutoCarto 8, (pp. 50-56).


