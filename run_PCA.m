%% TRAINING - PCA

disp('TRAINING - PRINCIPLE COMPONENT ANALYSIS');
K = N_FEATURES;
X = cellfun(@(w) w(:), TRAIN_WINDOWS, 'UniformOutput', false); % flatten out windows
X = [X{:}];
%
[eigenvecs eigenvals] = PCA_SVD(X);
%
feats1D = eigenvecs(:,1:K);
B_PCA = arrayfun(@(i) reshape(feats1D(:,i), WINDOW_WIDTH, WINDOW_WIDTH), 1:K, 'UniformOutput', false);

%% PLOT FEATURES

if plots
    Babspca = cellfun(@(b) abs(b.^2), B_PCA, 'UniformOutput', false);
    plot_imgs_rescale(Babspca, 'PCA: LEARNED FEATURES', 25, false);
    figure();
    semilogy(eigenvals, '-o');
    title('eigenvals from PCA');
end
    
%% RECONSTRUCT AND PLOT RECONSTRUCTED

if plots
    disp('RECONSTRUCTING - PCA');
    weights = learn_img_reconstruct2(TRAIN_WINDOWS, B_PCA, 0, 100, 500, 1E-5);
    reconstructed = arrayfun(@(k) img_reconstruct(weights(k,:), B_PCA), 1:length(TRAIN_WINDOWS), 'UniformOutput', false);
    plot_imgs_rescale(reconstructed, 'PCA: RECONSTRUCTED IMAGES', 49, false);
    
        
    % error normalized by num pixels
    reconstr_err = arrayfun(@(i) sum(sum((TRAIN_WINDOWS{i} - reconstructed{i}).^2)), 1:length(TRAIN_WINDOWS)) / (numel(TRAIN_WINDOWS{1}));
    figure();
    bar(reconstr_err);
    
    mean_reconstr_err = mean(reconstr_err);
    fprintf('mean reconstruction error (PCA) = %f\n', mean_reconstr_err);
end

%% Also plot weights (test correlation with eigenvalues)


if plots
    if ~exist('weights', 'var')
        weights = learn_img_reconstruct2(TRAIN_WINDOWS, B_PCA, 0, 100, 500, 1E-5);
    end
    lambda = 0; % recon only; no sparseness
    avg_weights = mean(abs(weights), 1);
    figure();
    semilogy(1:K, eigenvals(1:K), 'LineWidth', 2);
    hold on;
    semilogy(1:K, avg_weights(1:K), 'LineWidth', 2, 'Color', [0 0.8 0.25]);
    hold off;
    title('eigenvals from PCA vs weights from reconstruction');
    legend('eigenvals', 'reconstruction weights');
end