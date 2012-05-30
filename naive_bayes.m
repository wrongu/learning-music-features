% Richard Lange
% CS 74 HW 2
% Problem 4, part a modified for project
%
% Naive Bayes classifier with Laplacian Smoothing

function [PHI, prior] = naive_bayes(trainX, trainY)

    M = size(trainX, 2);
    N = size(trainX, 1);
    classes = unique(trainY);
    K = length(classes);
    
    PHI = zeros(N,K);
    
    for c=1:K
        X = trainX(:, ismember(trainY, classes(c)));
        PHI(:,c) = 
    end
    trainX0 = trainX(trainY==0, :);
    M0 = size(trainX0,1);
    trainX1 = trainX(trainY==1, :);
    M1 = size(trainX1,1);
    PHI = zeros(N,2);
    
    PHI(:,1) = (sum(trainX0,1) + 1) ./ (M0 + 2);
    PHI(:,2) = (sum(trainX1,1) + 1) ./ (M1 + 2);
    
    prior = sum(trainY) / M;
end