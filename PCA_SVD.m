% v = PCA_SVD(X)
%   computes eigenvectors (columns of v), which are the principle
%    components of X.
%   X is M column vectors (M data) of dimensionality N.
%
% To get the K principle components:
%
%	PC = v(:,1:K)
%
function [sorted_eigenvectors eigenvals] = PCA_SVD(X)
    [N,M] = size(X);
    mindim = min(N, M);
    X = X / sqrt(M);
    [U,S,~] = svd(X);
    eigenvals = diag(S(1:mindim, 1:mindim));
    eigenvals = eigenvals.^2;
    [eigenvals, sort_inds] = sort(eigenvals, 'descend');
    sorted_eigenvectors = U(:, sort_inds);
end