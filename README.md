Hierarchical two way agglomerative (Wards) consensus clustering

TO USE:

Download the files in this repository into a folder on your computer.

Put the input data files in the same folder. 

Use ClusteringScript.m to define parameters: input data file name, number of groups (N), and Z-Score Dimension type.

Z-Score Dimension types:
"FirstDimension"
"SecondDimension"
""  --> if the input data has already been z-scored. 

Run ClusteringScript.m. 

If you would like to modify the number of times the data gets resampled, see clusterSampling.m and look for numOfResamplings. 
