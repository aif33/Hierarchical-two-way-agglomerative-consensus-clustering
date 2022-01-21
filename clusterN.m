classdef clusterN   
    properties
        PercentSimilarityMatrix
        PercentSimiliarityMatrixSortedAndT
        EuclideanDistance
        
    end
    
    methods
        function obj = clusterN(percentSimilarity,percentSimilaritySortedAndT, euclideanDistance)
            obj.PercentSimilarityMatrix = percentSimilarity;
            obj.PercentSimiliarityMatrixSortedAndT = percentSimilaritySortedAndT;
            obj.EuclideanDistance = euclideanDistance;           
        end
    end
end

