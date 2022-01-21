function D = similarityMatrix(clusterMatrixAll)

N = size(clusterMatrixAll,1);
D = zeros(N,N);
for i=1:N 
 for j=1:i
     if (clusterMatrixAll(i) == clusterMatrixAll(j))
         D(i,j) = 1;
     else
         D(i,j) = 0;
     end
     
     D(j,i) = D(i,j);% D is the similarity matrix
 end
end

