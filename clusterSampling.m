function clustSampling = clusterSampling(dataFileName, numberOfGroups, zScoreDimensionType)
    
    %{

    inputs and outputs: 

    dataFileName -->  file name to find the data with sample names in the left most
    column, features we are measuring in the top most row, and values in
    the intersections
  
              feature1   feature2  feature3... featureN
     sample1    a           b        c           d
     sample2    e           f        g           h
        .       .           .        .           . 
        .       .           .        .           . 
        .       .           .        .           .
     sampleN    i           j        k           l


    
     numberOfGroups -> number of groups to be used in clustering
     
     
     clustSampling will be a list of a class 'ClusterInfo',
     where each instance of 'ClusterInfo' contained in the list represents 
     instance number N, for 1 <= N <= numberOfGroups.

     an instance n of 'ClusterInfo' contains:
     (a) percent similarity matrix, 
     (b) transformed and sorted percent similarity matrix 
     (c) euclidean distance between matrix of ones and (b)

     %}
    
    clustSampling = clusterN.empty;

    
    [NUM,TXT,RAW] = xlsread(dataFileName);

    %eliminate first column and first row labels. then we are going to randomly
    %sample 80 percent of the data and calcuate z scores of this randomly
    %selected 80 percent.

    numberOfSamples = size(NUM,1); 
	
	numOfResamplings = 400;

    allRks = zeros(numOfResamplings, numberOfSamples);

    % generate indexes of which samples we selected randomly with
    % 80 % of samples selected
    % r(k) == 0 ? picked sample k : did not pick sample k
    % where k is the index of the sample in the vector of sample names from
    % our data file
    % get 400 pages of z scores --> see numOfResamplings

    numberOfRandomRows = round(numberOfSamples * .8);
    
    zScoresSampledPages = zeros(numberOfRandomRows, size(NUM,2), numOfResamplings);
    
    for cnt = 1:numOfResamplings
        
        k = randperm(numberOfSamples, numberOfRandomRows);
        r = true(1,numberOfSamples);
        r(k) = false;

        allRks(cnt,:) = r;
        
        numSampled = double.empty;

        for i = 1:numberOfSamples
            if r(i) == 0 %if r is 0, we picked that sample
                numSampled(end+1,:) = NUM(i,:);
            end
        end
        		
		
	if zScoreDimensionType == "FirstDimension"
			
			zScoresSampled = zscore(numSampled,0,1);  %z score of randomly sampled data in first dimension			
			zScoresSampledPages(:,:,cnt) = zScoresSampled(:,:);	
			
        elseif zScoreDimensionType == "SecondDimension"			
			zScoresSampled = zscore(numSampled,0,2);  %z score of randomly sampled data in second dimension			
			zScoresSampledPages(:,:,cnt) = zScoresSampled(:,:);
			
        elseif zScoreDimensionType == ""
            		zScoresSampled = numSampled;  %input is already z scored  			
			zScoresSampledPages(:,:,cnt) = zScoresSampled(:,:);
	else
		error('Invalid Z-Score Dimension Type: ' + zScoreDimensionType);
	end			       
    end
      
    for N = 1:numberOfGroups
               
        numeratorMatrix = zeros(numberOfSamples, numberOfSamples);

        denominatorMatrix = zeros(numberOfSamples, numberOfSamples);
        
        for cnt = 1:numOfResamplings

            r = allRks(cnt,:); 

            zScoresSampled = zScoresSampledPages(:,:,cnt);

            clusterMatrixOfSampled = clusterMatrix(zScoresSampled,N);

            %we are going to take the randomly sampled groups and create a one column
            %matrix with the rest of the groups we did not sample and assign "fake"
            %group numbers to the groups that we did not sample

            fakeGroupNumber = 10000;

            indexOfSampled = 1;

            clusterMatrixAll = zeros(i, 1);

            clusterMatrixAllForDenominator = zeros(i,1);


            for k = 1:numberOfSamples

                if r(k) == 0
                     clusterMatrixAll(k) = clusterMatrixOfSampled(indexOfSampled);
                     clusterMatrixAllForDenominator(k) = 1;
                     indexOfSampled = indexOfSampled + 1;
                else 
                     clusterMatrixAll(k) = fakeGroupNumber;
                     clusterMatrixAllForDenominator(k) = fakeGroupNumber;
                     fakeGroupNumber = fakeGroupNumber + 1;
                end

            end

            similarityMatrixNumerator = similarityMatrix(clusterMatrixAll);

            similarityMatrixDenominator = similarityMatrix(clusterMatrixAllForDenominator);

            numeratorMatrix = numeratorMatrix + similarityMatrixNumerator; 

            denominatorMatrix = denominatorMatrix + similarityMatrixDenominator;

        end
               
        sampleNames = TXT(2:end,1);

        percentSimilarityMatrix = numeratorMatrix./denominatorMatrix;

        clusterSimilarity = clusterMatrix(percentSimilarityMatrix,N);
        
        %now we will compute transformed percent similarity matrix

        sampleIndexAndGroups = zeros(numberOfSamples,2);

        sampleIndexAndGroups(:,1) = 1:numberOfSamples;

        sampleIndexAndGroups(:,2) = clusterSimilarity;

        sampleIndexSortedByGroups = sortrows(sampleIndexAndGroups,2);

        mappedSampleIntersection = containers.Map('KeyType','char','ValueType','double');

        percentSimilaritySortedAndT = cell(numberOfSamples +1,numberOfSamples +1);

        for a = 1:numberOfSamples
            %a is our row index

            groupNumberRow = clusterSimilarity(a);

            rowName = string(sampleNames(a));

            percentSimilaritySortedAndT(a+1,1) = sampleNames(sampleIndexSortedByGroups(a,1));

            for b = 1:numberOfSamples
                %b is our column index

               colName = string(sampleNames(b)); 

               groupNumberCol = clusterSimilarity(b);

               if (groupNumberRow == groupNumberCol)
                   value = percentSimilarityMatrix(a,b);
               else
                   value = 1 - percentSimilarityMatrix(a,b);
               end

               mappedSampleIntersection(rowName + '_' + colName) = value;

               percentSimilaritySortedAndT(1,b+1) = sampleNames(sampleIndexSortedByGroups(b,1));

           end
        end

        for a = 1:numberOfSamples

            rowName = string(percentSimilaritySortedAndT(a+1,1));

            for b = 1:numberOfSamples

                colName = string(percentSimilaritySortedAndT(1,b+1));

                percentSimilaritySortedAndT(a+1,b+1) = num2cell(mappedSampleIntersection(rowName + '_' + colName));

            end

        end
        
        percentSimilarityValuesSortedAndT = cell2mat(percentSimilaritySortedAndT(2:numberOfSamples + 1, 2:numberOfSamples + 1)); 
        
        %now we will compute the euclidean distance 
        
        matrixOfOnes = ones(numberOfSamples);
        
        x = matrixOfOnes - percentSimilarityValuesSortedAndT;

        y = x.^2;

        sumFinal = sum(y,'All');

        finalValue = (sqrt(sumFinal) / numberOfSamples) * 100;
        
        clustSampling(N) = clusterN(percentSimilarityMatrix, percentSimilaritySortedAndT, finalValue);
               
    end
        
end 
