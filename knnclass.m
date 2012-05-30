% trainX, testX should be NxM (M points of dim N)

function testY = knnclass(trainX, trainY, testX, K)

%      IDXs = arrayfun(@(i) knnsearch(trainX, testX(i,:), 'K', K), 1:size(testX,2), 'UniformOutput', false);
     IDXs = arrayfun(@(i) knnsearch(trainX, testX, 'K', K), 1:size(testX,2), 'UniformOutput', false);
     
     if strcmp(class(trainY), 'double')
         testY = zeros(size(testX,2),1);
         for i=1:length(IDXs)
             votes = trainY(IDXs{i});
             testY(i) = mode(votes);
         end
     elseif iscell(trainY) && ischar(trainY{1})
        testY = cell(size(testX,2),1);
        all_classes = unique(trainY);
        doubY = cellfun(@(y) find(ismember(all_classes, y)), trainY);
        for i=1:length(IDXs)
             votes = doubY(IDXs{i});
             testY{i} = all_classes{mode(votes)};
         end
     end
%     Mtrain = size(trainX,2);
% 
%     testY = zeros(size(testX,2));
%     
%     for i=1:size(testX,2)
%         dists = arrayfun(@(m) norm(trainX(:,m)-testX(:,i)), 1:Mtrain);
%         [~, sortinds] = sort(dists);
%         testY(i) = mode(trainY(sortinds(1:K)));
%     end
end