clust = clusterSampling("NewBLCAsamples.xlsx", 8, "FirstDimension");    %possible inputs -> "FirstDimension", "SecondDimension", "" 
maxGroups = size(clust,2);

x = zeros(1,maxGroups);
y = zeros(1,maxGroups);

for i = 1:maxGroups
    x(1,i) = i;
    y(1,i) = clust(i).EuclideanDistance;
       
end

plot(x,y);


