function clustMatrix = clusterMatrix(inputMatrix, numberOfGroups)

%get cluster matrix from N groups, defined by numberOfGroups

 linkageMatrix = linkage(inputMatrix, 'ward');
 clustMatrix = cluster(linkageMatrix,'MaxClust',numberOfGroups);
end

