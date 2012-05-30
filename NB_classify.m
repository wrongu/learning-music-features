% Richard Lange
% CS 74 HW 2
% Problem 4, part a
%
% Naive Bayes classification (test-time)

function class = NB_classify(X, PHI, prior)
    
    N = size(PHI, 1);

    likelihood_0 = exp(sum(arrayfun(@(j) log(PHI(j,1)^X(j) * (1-PHI(j,1))^(1-X(j))), 1:N)));
    likelihood_1 = exp(sum(arrayfun(@(j) log(PHI(j,2)^X(j) * (1-PHI(j,2))^(1-X(j))), 1:N)));
    
    posterior = likelihood_1 * prior / (likelihood_0*(1-prior) + likelihood_1*prior);

    class = round(posterior);
end