% this is the *main learning algorithm* of my project
% source: Oshausen & Field, 1996.

function [A, PHI, phi_norm_hist, mean_err, mean_loss, mean_dense, phi_init] = ...
    par_iterative_sparse_coding(train_set, n_features, lambda, sigma, max_all_iter, ...
                                max_inner_iter, A_conv, phi_conv, PHI_INIT, images_per_phi_update)

	if nargin < 10 || images_per_phi_update > length(train_set)
        images_per_phi_update = length(train_set);
    end
                            
    K   = length(train_set);
    PHI = cell(n_features, 1); % cell array of basis matrices
    A   = cell(K,1);
    for i=1:K
        A{i} = rand(1, n_features)*2-1;
    end
    
    if nargin < 9 || isempty(PHI_INIT);
        % initialize PHI to random pixels
        %   (another thing to try would be to init. to random training
        %   features, or distant training features like in kmeans..)
        for i=1:n_features
            PHI{i} = rand(size(train_set{1})) * 2 - 1;
        end
    else
        PHI = PHI_INIT;
        assert(n_features == length(PHI));
    end
    
    phi_init = PHI;
    
    % choices for S function: uncomment a pair
    % (S represents sparseness of A)
    S     = @(w) -exp(-w^2);
    dS_dA = @(w) 2*w*exp(-w^2);
    d2S_dA2 = @(w) exp(-w^2)*(2-4*w^2);
%     S     = @(w) log(1 + w^2);
%     dS_dA = @(w) 2*w / (1+w^2);
%     S     = @(w) abs(w);
%     dS_dA = @(w) sign(w);
    
    learn_rate_A = 0.01;
    learn_rate_phi = 0.1;
    
    phi_norm_hist = 0;
    mean_err = 0;
    mean_loss = 0;
    mean_dense = 0;
    mean_t_elapse = 0;
    TRAIN_IMGS_START_INDEX = 1;
    
    for outer=1:max_all_iter
        tstart = tic;
        % loop over training matrices, optimize A for each
        fprintf('outer loop %d', outer);
        C = arrayfun(@(i) ...
                arrayfun(@(j) ...
                    sum(sum(PHI{i} .* PHI{j})), ...
                    1:n_features), ...
                1:n_features, 'UniformOutput', false ...
            );
        C = vertcat(C{:}); % matrix instead of cell array of row vectors
        
        train_imgs_end_index = min(length(train_set), TRAIN_IMGS_START_INDEX+images_per_phi_update-1);
        range = TRAIN_IMGS_START_INDEX:train_imgs_end_index;
        TRAIN_IMGS_START_INDEX = train_imgs_end_index+1;
        remainder = images_per_phi_update - length(range);
        if remainder > 0
            range = [range 1:remainder];
            TRAIN_IMGS_START_INDEX=remainder+1;
        end        
        TRAIN_SET_TEMP = train_set(range);
        A_TEMP = A(range);
        parfor k=1:images_per_phi_update,
            % optimize A iteratively (gradient descent on error function
            %   with respect to A), for given basis matrices
            
            % set up variables for gradient descent to reconstruct image k
            A_k = A_TEMP{k};
            img_k = TRAIN_SET_TEMP{k};
            % b(i) is the first term on the right side of equation 5
            %   (Oshausen 1996)
            b = arrayfun( @(i) ...
                    sum(sum( PHI{i} .* img_k )), ...
                    1:n_features ...
                );
            converged = false;
            iter = 1;
            
            %  --- error computation for debugging --- 
%             err_start = error_func(A_k, PHI, img_k, S, lambda, sigma);
%             errs = err_start;
%             norm_dA_all = 0;
            % ----------------------------------------
            
            deriv_recon = 0;
            deriv_sparse = 0;
            % GRADIENT DESCENT LOOP: min Error with respect to  A
            % TODO - check if error actually decreased. if not, smaller
            %   step, repeat GD?
            while ~converged
                % C_weighted(i) is the second term on the right side of 
                %   equation 5 (Olshausen 1996)
                %   (sum of Cij * Aj) is computed using vector inner-product
                C_weighted = C * A_k';

%                 dE_dA = zeros(1, n_features);
%                 recon_part = zeros(1, n_features);
%                 sparse_part = zeros(1, n_features);
%                 for i=1:n_features
%                     recon_part(i) = abs(- b(i) + C_weighted(i));
%                     sparse_part(i) = abs(lambda*dS_dA(A_k(i)/sigma)/sigma);
%                     dE_dA(i) = - b(i) + C_weighted(i) + lambda*dS_dA(A_k(i)/sigma)/sigma;
%                 end
%                 figure();
%                 plot(recon_part, '-o');
%                 hold on;
%                 plot(sparse_part, '-ro');
%                 ratio = recon_part ./ sparse_part;
%                 plot(ratio, '-go');
%                 line([0,n_features], [mean(ratio), mean(ratio)], 'LineStyle', '--', 'Color', [0 1 0]);
%                 hold off;
%                 legend('recon', 'sparse', 'ratio');
%                 pause;

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
%                     fprintf('convergence on loop %d\n', iter);
                    converged = true;
%                     fprintf('converged after %d\n',iter);
                elseif iter >= max_inner_iter
                    converged = true;
%                     fprintf('\n');
                end
                
                % ---- keep track of data for debugging ----
%                 norm_dA_all(iter) = norm_dA;
%                 errs = vertcat(errs, error_func(A_k, PHI, img_k, S, lambda, sigma));
                % ------------------------------------------
                iter = iter+1;
            end
            
            % UPDATE A
            A_TEMP{k} = A_k;

            % DEBUG PLOTS
%             h = figure();
%             subplot(1,2,1);
%             plot(errs, '-o');
%             title('error convergence');
%             subplot(1,2,2);
%             plot(norm_dA_all, '-o');
%             title('L-inf norm of dE_dA');
%             suptitle(sprintf('outer loop %d, k loop %d', outer, k));
%             pause;
%             close(h);
        end
        
        A(range) = A_TEMP;

        % optimize PHI given current A for best avg reconstruction of train images
        reconstructed = arrayfun(@(k) img_reconstruct(A_TEMP{k}, PHI), 1:images_per_phi_update, 'UniformOutput', false);
        max_abs_phi_diff = 0;
        for i=1:n_features
            weighted_diffs = arrayfun(@(k) A_TEMP{k}(i) * (TRAIN_SET_TEMP{k} - reconstructed{k}), 1:images_per_phi_update, 'UniformOutput', false);
            avg_diff = sum(cat(3, weighted_diffs{:}), 3) / K;
            max_abs_phi_diff = max(  max_abs_phi_diff,  max(max(abs(avg_diff)))  );
            PHI{i} = PHI{i} + (learn_rate_phi * avg_diff);
        end

        phi_norm_hist(outer) = max_abs_phi_diff;
        mean_err(outer) = 0;
        mean_loss(outer) = 0;
        mean_dense(outer) = 0;
        for k=1:K
            [err, loss, dense] = error_func(A{k}, PHI, train_set{k}, S, lambda, sigma);
            mean_err(outer) = mean_err(outer) + err;
            mean_loss(outer) = mean_loss(outer) + loss;
            mean_dense(outer) = mean_dense(outer) + dense;
        end
        
        mean_err(outer) = mean_err(outer) / K;
        mean_loss(outer) = mean_loss(outer) / K;
        mean_dense(outer) = mean_dense(outer) / K;
        
        % CONVERGENCE TEST
        if max_abs_phi_diff < phi_conv
            fprintf('converged outer loop (phi) after %d iterations\n', outer);
            break
        end
        
        telapsed = toc(tstart);
        div = min(outer, 100);
        mean_t_elapse = mean_t_elapse + (telapsed - mean_t_elapse) / div;
        nremain = max_all_iter - outer;
        sec_remain = floor(mean_t_elapse * nremain);
        min_remain = floor(sec_remain / 60);
        sec_leftover = mod(sec_remain, 60);
        curtime = clock;
        hms = curtime(4:6);
        h_remain = floor(min_remain/60);
        min_leftover = mod(min_remain, 60);
        eta_s = floor(hms(3) + sec_leftover);
        eta_m = floor(hms(2) + min_leftover + floor(eta_s/60));
            eta_s = mod(eta_s, 60);
        eta_h = floor(hms(1) + h_remain + floor(eta_m/60));
            eta_m = mod(eta_m, 60);
        if(eta_h > 12)
            eta_h = mod(eta_h, 12);
        end
        eta = sprintf('%02d:%02d:%02d', floor(eta_h), floor(eta_m), floor(eta_s));
        if min_remain > 0
            fprintf('\tETR: %3d min %2d sec :: ETA: %s\n', min_remain, sec_leftover, eta);
        else
            fprintf('\tETR: %02d sec :: ETA: very soon\n', sec_remain);
        end
        
%         figure();
%         plot(errs, '-o');
%         title('Error convergence for inner loop over PHI');
%         plot_imgs_rescale(reconstructed, ['RECONSTRUCTED IMAGES AT ITERATION ' num2str(outer)]);
%         plot_imgs_rescale(PHI, ['CONVOLUTION FEATURES AT ITERATION ' num2str(outer)]);
        %pause;
    end
    A = vertcat(A{:});
    fprintf('\niterative_sparse_encoding finished after %d outer loops\n', outer);
end

function [E, loss_info, denseness] = error_func(A, PHI, test_img, S, lambda, sigma)
    
    % error from two sources: lost information in reconstruction, and lack
    %   of sparseness (denseness)
    % Larger lambda means more emphasis on sparseness criteria
    
    % lost info: sum of squared diff of reconstructed img vs given img
    reconstructed = img_reconstruct(A, PHI);
    diff = test_img - reconstructed;
    loss_info = sum(sum(diff .^ 2));
    
    % denseness: based on given function S, which is small (or largely
    %   negative) for A(i) closest to zero
    denseness = sum( arrayfun(@(i) S(A(i)/sigma), 1:length(PHI)) );
    
    E = loss_info + lambda * denseness;
end