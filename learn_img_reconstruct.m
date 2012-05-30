function A = learn_img_reconstruct(train_imgs, basis_imgs, max_inner_iter, A_conv)

    % copy/pasted from iterative_sparse_coding, slightly modified
    %   like a single iteration of ISC, returning weights for
    %   reconstruction
    
    K = length(train_imgs);
    n_features = length(basis_imgs);
    
    A = rand(K, n_features);
    learn_rate_A = 0.01;
    
    C = arrayfun(@(i) ...
            arrayfun(@(j) ...
                sum(sum(basis_imgs{i} .* basis_imgs{j})), ...
                1:n_features), ...
            1:n_features, 'UniformOutput', false ...
        );
    C = vertcat(C{:}); % matrix instead of cell array of row vectors
    
    for k=1:K
        A_k = A(k,:);
        img_k = train_imgs{k};
        % b(i) is the first term on the right side of equation 5
        %   (Oshausen 1996)
        b = arrayfun( @(i) ...
                sum(sum( basis_imgs{i} .* img_k )), ...
                1:n_features ...
            );
        converged = false;
        iter = 1;
        while ~converged
            % C_weighted(i) is the second term on the right side of 
            %   equation 5 (Olshausen 1996)
            %   (sum of Cij * Aj) is computed using vector inner-product
            C_weighted = C * A';

            % partial derivatives of error 'E' w.r.t. Aj
            dE_dA = arrayfun(@(i) ...
                        - b(i) + C_weighted(i), ...
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
    end

    % UPDATE A
    A(k,:) = A_k;
end
    