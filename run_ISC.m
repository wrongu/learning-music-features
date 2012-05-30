%% TRAINING - ISC

disp('TRAINING - ITERATIVE SPARSE CODING');


if parallel && pool > 0
    curpool = matlabpool('size');
    if curpool && curpool ~= pool
        matlabpool('close');
    elseif ~curpool
        eval(sprintf('matlabpool(%d)', pool));
    end
    PHI_INIT = {};
    if exist('B_ISC', 'var')
        PHI_INIT = B_ISC;
        fprintf('Using previous B_ISC as initial PHI\n\n');
    end
    [A_ISC, B_ISC, b_hist_orig, mean_err_orig] = par_iterative_sparse_coding(TRAIN_WINDOWS, N_FEATURES, lambda, sigma, outer, inner, 0.01, 0.001, PHI_INIT, NUM_IMG_PER_PHI_UPDATE);
else
    if matlabpool('size')
        matlabpool close;
    end
    [A_ISC, B_ISC, b_hist_orig, mean_err_orig] = par_iterative_sparse_coding(TRAIN_WINDOWS, N_FEATURES, lambda, sigma, outer, inner, 0.01, 0.001, PHI_INIT, NUM_IMG_PER_PHI_UPDATE);
end
%
%
%

%% PLOT ERROR CONVERGENCE

cut=1;
mean_err = mean_err_orig(cut:end);
b_hist = b_hist_orig(cut:end);

if exist('mean_err_old','var')
    mean_err = [mean_err_old, mean_err];
    b_hist   = [b_hist_old, b_hist];
end

if plots
    figure();
    subplot(1,2,1);
    plot(mean_err, '-');
    xlabel('outer iteration');
    ylabel('mean error for all imgs');
    title('Error vs. Iteration');
    subplot(1,2,2);
    plot(b_hist, '-');
    xlabel('outer iteration');
    ylabel('L-inf norm of delta-PHI');
    title('delta-PHI vs. Iteration');
    suplabel('ISC convergence plots', 't');
end
    
%% PLOT RECONSTRUCTED

if plots
    reconstructed = arrayfun(@(k) img_reconstruct(A_ISC(k,:), B_ISC), 1:length(TRAIN_WINDOWS), 'UniformOutput', false);
    
    % error normalized by num pixels
    reconstr_err = arrayfun(@(i) sum(sum((TRAIN_WINDOWS{i} - reconstructed{i}).^2)), 1:length(TRAIN_WINDOWS)) / (numel(TRAIN_WINDOWS{1}));
    figure();
    subplot(1,2,1);
    bar(reconstr_err);
    subplot(1,2,2);
    bar(sort(reconstr_err));
    
    mean_reconstr_err = mean(reconstr_err);
    fprintf('mean reconstruction error (ISC) = %f\n', mean_reconstr_err);
    
    pause;
    plot_imgs_rescale(reconstructed, 'ISC: RECONSTRUCTED IMAGES', 49, false);
end

%% re-learn reconstruction more detailed, try again (from run_PCA)
% NOTE: this doesn't make it any better, really..

if plots
    disp('RECONSTRUCTING - ISC');
    weights = learn_img_reconstruct2(TRAIN_WINDOWS, B_ISC, 0, 100, 500, 1E-5);
    reconstructed = arrayfun(@(k) img_reconstruct(weights(k,:), B_ISC), 1:length(TRAIN_WINDOWS), 'UniformOutput', false);
    plot_imgs_rescale(reconstructed, 'ISC: RE-LEARNED RECONSTRUCTED IMAGES', 49, false);
    
        
    % error normalized by num pixels
    reconstr_err = arrayfun(@(i) sum(sum((TRAIN_WINDOWS{i} - reconstructed{i}).^2)), 1:length(TRAIN_WINDOWS)) / (numel(TRAIN_WINDOWS{1}));
    figure();
    bar(reconstr_err);
    
    mean_reconstr_err = mean(reconstr_err);
    fprintf('mean reconstruction error (ISC relearn) = %f\n', mean_reconstr_err);
end
%% PLOT FEATURES

if plots
    % Order features by how used they are in reconstruction
    %   (an attempt to put most 'significant' features first)
    A_weights = mean(abs(A_ISC),1);
    [sorted_A,sort_inds] = sort(A_weights, 'descend');
    Babs = cellfun(@(b) abs(b.^2), B_ISC, 'UniformOutput', false);
    plot_imgs_rescale(Babs(sort_inds), 'ISC: LEARNED FEATURES', 25, false);
    
    figure();
    plot(sorted_A, '-o');
    title('Relative weights of features');
    
    N = 5;
    figure();
    plot(A_ISC(1:10,:)', 'LineWidth', 2);
end

%% RE-PLOT TRAIN WINDOWS

if plots
    cut=25;
    plot_imgs_rescale(TRAIN_WINDOWS, 'train windows', 25, false);
    if exist('test_type', 'var') && strcmp(test_type, 'g_grate')
        plot_imgs_rescale(components, [num2str(G) ' grating components of train imgs (ideal features)'], 25, false);
    end
end