function weights = ...    
    learn_img_reconstruct2(train_set, features, lambda, sigma, max_inner_iter, A_conv)

    K   = length(train_set);
    PHI = features;
    weights   = cell(K,1);
    n_features = length(PHI);
    for i=1:K
        weights{i} = rand(1, n_features)*2-1;
    end
    
    % choices for S function: uncomment a pair
    % (S represents sparseness of A)
%     S     = @(w) -exp(-w^2);
    dS_dA = @(w) 2*w*exp(-w^2);
%     d2S_dA2 = @(w) exp(-w^2)*(2-4*w^2);
%     S     = @(w) log(1 + w^2);
%     dS_dA = @(w) 2*w / (1+w^2);
%     S     = @(w) abs(w);
%     dS_dA = @(w) sign(w);
    
    learn_rate_A = 0.01;
    
    C = arrayfun(@(i) ...
            arrayfun(@(j) ...
                sum(sum(PHI{i} .* PHI{j})), ...
                1:n_features), ...
            1:n_features, 'UniformOutput', false ...
        );
    C = vertcat(C{:}); % matrix instead of cell array of row vectors
    parfor k=1:K,
        % optimize A iteratively (gradient descent on error function
        %   with respect to A), for given basis matrices

        % set up variables for gradient descent to reconstruct image k
        A_k = weights{k};
        img_k = train_set{k};
        % b(i) is the first term on the right side of equation 5
        %   (Oshausen 1996)
        b = arrayfun( @(i) ...
                sum(sum( PHI{i} .* img_k )), ...
                1:n_features ...
            );
        converged = false;
        iter = 1;
        % GRADIENT DESCENT LOOP: min Error with respect to  A
        % TODO - check if error actually decreased. if not, smaller
        %   step, repeat GD?
        while ~converged
            % C_weighted(i) is the second term on the right side of 
            %   equation 5 (Olshausen 1996)
            %   (sum of Cij * Aj) is computed using vector inner-product
            C_weighted = C * A_k';

            % partial derivatives of error 'E' w.r.t. Aj
            dE_dA = arrayfun(@(i) ...
                        - b(i) + C_weighted(i) + lambda*dS_dA(A_k(i)/sigma)/sigma, ...
                        1:n_features ...
                    );

            % Gradient Descent
            A_k = A_k - learn_rate_A * dE_dA;

            % convergence check
            norm_dA = max(abs(dE_dA));
            if norm_dA < A_conv
                converged = true;
            elseif iter >= max_inner_iter
                converged = true;
            end

            iter = iter+1;
        end

        % UPDATE A
        weights{k} = A_k;

    end
    weights = vertcat(weights{:});
end