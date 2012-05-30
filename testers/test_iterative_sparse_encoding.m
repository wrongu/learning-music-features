clc;
if ~exist('test_type', 'var')
    test_type = 'g_grate';
end
if ~exist('plots', 'var')
    plots=false;
end
if(~exist('parallel', 'var'))
    parallel = false;
end
if(~exist('pool', 'var'))
    pool = 2;
end

N_FEATURES = 50;
WINDOW_WIDTH = 12;

%% RANDOM PIXELS

if strcmp(test_type, 'pix')
for i=1:N_TRAIN
    mat = exprnd(0.15, WINDOW_WIDTH, WINDOW_WIDTH);
    matmax = max(max(mat));
    if(matmax > 1)
        mat = mat/matmax;
    end
    TRAIN_WINDOWS{i} = mat;
end
if plots
plot_m_n_imgs(TRAIN_WINDOWS);
suptitle('TRAIN IMAGES');
end
end

%% GRATINGS

if strcmp(test_type, 'sparse_grate')
SPARSITY = 0.7;

for i=1:N_TRAIN
    mat = zeros(WINDOW_WIDTH);
    T = rand*WINDOW_WIDTH;
    shift = rand*T;
    rot = rand*2*pi;
    c = cos(rot);
    s = sin(rot);
    for x=1:WINDOW_WIDTH
        for y=1:WINDOW_WIDTH
            x_rot = c*x + s*y;
            mat(x, y) = sin(2*pi*x_rot/T + shift)^2;
        end
    end
    % sparsify by 'squashing' grating by small scaling factor, randomly
    inds = randperm(WINDOW_WIDTH*WINDOW_WIDTH);
    n_sparse = floor(WINDOW_WIDTH^2*(SPARSITY));
    mat(inds(i:n_sparse)) = mat(inds(i:n_sparse)) .* 0.5;
    TRAIN_WINDOWS{i} = mat;
end
if plots
plot_m_n_imgs(TRAIN_WINDOWS);
suptitle('TRAIN IMAGES');
end
end

%% Sparse gratings as weighted sum of sines (sparse weights)

if strcmp(test_type, 'sparse_grate2')
N_TRAIN = 25;
N_FEATURES = 10;
WINDOW_WIDTH = 16;
range = 1:WINDOW_WIDTH^2;
TRAIN_WINDOWS = cell(N_TRAIN, 1);
for i=1:N_TRAIN
    coeffs = exprnd(0.15, WINDOW_WIDTH^2, 1);
    shifts = rand(1, WINDOW_WIDTH^2) .* range / 2;
    sines = arrayfun(@(T) coeffs(T)*sin(range*pi/ T + shifts(T)), range, 'UniformOutput', false);
    grating1D = sum( cat(1, sines{:}), 1);
    grating2D = reshape(grating1D, WINDOW_WIDTH, WINDOW_WIDTH);
    TRAIN_WINDOWS{i} = grating2D;
end
if plots
% TRAIN_IMGS = cellfun(@(img) (img-min)/(max+min));
plot_imgs_rescale(TRAIN_WINDOWS, 'TRAIN IMAGES: SPARSE GRATING');
end
end

%% SUM OF G GRATINGS, G << K

if strcmp(test_type, 'g_grate')
G = 5;
WINDOW_WIDTH = 16;
N_TRAIN = 25;
N_FEATURES = G;

components = cell(G,1);

for i=1:G
    mat = zeros(WINDOW_WIDTH);
    T = rand*WINDOW_WIDTH*2;
    shift = rand*T;
    rot = rand*2*pi;
    c = cos(rot);
    s = sin(rot);
    for x=1:WINDOW_WIDTH
        for y=1:WINDOW_WIDTH
            x_rot = c*x + s*y;
            mat(x, y) = sin(2*pi*x_rot/T + shift);
        end
    end
    components{i} = mat;
end

range = 1:WINDOW_WIDTH^2;
TRAIN_WINDOWS = cell(N_TRAIN, 1);
avg_weights = zeros(G,1);
avg_sparseness = 0;
for i=1:N_TRAIN
	weights = exprnd(0.15, G, 1)*(round(rand)*2-1);
    avg_weights = avg_weights + (abs(weights)-avg_weights)/i;
    avg_sparseness = avg_sparseness + (-denseness(weights) - avg_sparseness)/i;
    weighteds = arrayfun(@(j) weights(j) * components{j}, 1:G, 'UniformOutput', false);
    TRAIN_WINDOWS{i} = sum(cat(3, weighteds{:}), 3);
end

fprintf('components avg sparseness: %f\n', avg_sparseness);

[~, weights_order] = sort(avg_weights,'descend');
components = components(weights_order);

if plots
    plot_imgs_rescale(components, [num2str(G) ' grating components of train imgs (ideal features) in order'], 25, false);
    plot_imgs_rescale(TRAIN_WINDOWS, 'TRAIN IMAGES: SUM OF A FEW GRATINGS', 25);
end

end

%% REAL SIMPLE EDGES

if strcmp(test_type, 'black_white')
WINDOW_WIDTH = 4;
mat = zeros(WINDOW_WIDTH);
TRAIN_WINDOWS = cell(4,1);
N_TRAIN = 4;
N_FEATURES = 3;
mat(1:WINDOW_WIDTH/2, :) = 1;
TRAIN_WINDOWS{1} = mat;
TRAIN_WINDOWS{2} = 1-mat;
TRAIN_WINDOWS{3} = TRAIN_WINDOWS{1}';
TRAIN_WINDOWS{4} = TRAIN_WINDOWS{2}';
plot_m_n_imgs(TRAIN_WINDOWS);
suptitle('TRAIN IMAGES');
end

%% TRAIN - PCA

run_PCA;
fprintf('PCA DONE\n--------------------\n');

%% TRAIN - ISC

if ~exist('sigma', 'var')
    mean_variance = 0;
    for k=1:length(TRAIN_WINDOWS)
        mean_variance = mean_variance + (var(TRAIN_WINDOWS{k}(:), 1) - mean_variance)/k;
    end
    fprintf('MEAN VARIANCE = %f\n', mean_variance);
    sigma = mean_variance;
end
if ~exist('lambda', 'var')
    lambda = 0.14 * sigma;
end
if ~exist('outer', 'var')
    outer = 4000;
end
if ~exist('inner', 'var')
    inner = 60;
end
if ~exist('NUM_IMG_PER_PHI_UPDATE', 'var');
    NUM_IMG_PER_PHI_UPDATE = 100;
end

run_ISC;

%% SAVE RESULTS

save_TEST_results;

%% TRAIN MULTIPLE LAMBDA

% lambdas = [0.1, 1, 10, 100];
% 
% for i=1:length(lambdas)
%     l = lambdas(i);
%     [w, b, b_hist, mean_err] = iterative_sparse_coding(TRAIN_IMGS, N_FEATURE, l, 1, 500, 500, 0.001, 0.001);
%     fprintf('\nDONE LAMBDA = %f\n\n', l);
%     
%     % plot for this lambda
%     plot_imgs_rescale(b, sprintf('LEARNED CONVOLUTION FEATURES :: lambda = %f', l));
%     reconstructed = arrayfun(@(k) img_reconstruct(w(k,:), b), 1:length(TRAIN_IMGS), 'UniformOutput', false);
%     plot_imgs_rescale(reconstructed, sprintf('Reconstructed input images :: lambda = %f', l));
% end
% disp('DONE');
% 
% %% PLOT ERROR CONVERGENCE
% 
% figure();
% subplot(1,2,1);
% plot(mean_err, '-o');
% xlabel('outer iteration');
% ylabel('mean error for all imgs');
% title('Error vs. Iteration');
% hold on;
% plot(mean_loss, '-ro');
% plot(lambda*mean_dense, '-go');
% hold off;
% legend('total err', 'loss', 'lambda*dense');
% subplot(1,2,2);
% plot(b_hist, '-o');
% xlabel('outer iteration');
% ylabel('L-inf norm of delta-PHI');
% title('delta-PHI vs. Iteration');
% 
% %% PLOT RECONSTRUCTIONS
% 
% reconstructed = arrayfun(@(k) img_reconstruct(w(k,:), b), 1:length(TRAIN_WINDOWS), 'UniformOutput', false);
% plot_imgs_rescale(reconstructed, sprintf('Reconstructed input images :: lambda = %g', lambda), 100, false);
% 
% %% PLOT FEATURES
% 
% plot_imgs_rescale(b, sprintf('LEARNED CONVOLUTION FEATURES :: lambda = %g', lambda), 100, false);
% 
% 
% %% RE-PLOT TEST IMGS
% 
% plot_imgs_rescale(TRAIN_WINDOWS, sprintf('TRAINING IMAGES :: lambda = %g', lambda), 25, false);
