if ~exist('composers', 'var')
    composers = {'joplin', 'chopin'};
end

if ~exist('EXAMPLE_LENGTH', 'var')
    EXAMPLE_LENGTH = 100;
end

get_song_matrices;

if ~exist('X_ISC', 'var')
    [X_ISC Y_ISC] = construct_subsong_features(song2d_cell, all_composers, EXAMPLE_LENGTH, B_ISC);
end

if ~exist('X_PCA', 'var')
    [X_PCA Y_PCA] = construct_subsong_features(song2d_cell, all_composers, EXAMPLE_LENGTH, B_PCA);
end

% RANDOM features as benchmark
if ~exist('X_rand', 'var')
    RAND_FEATS = cell(size(B_ISC));
    DIM = size(B_ISC{1},1);
    parfor i=1:length(RAND_FEATS)
        RAND_FEATS{i} = rand(DIM)*2-1;
    end
    [X_rand Y_rand] = construct_subsong_features(song2d_cell, all_composers, EXAMPLE_LENGTH, RAND_FEATS);
end

PERCENT_TRAIN_SET = 0.7;
NUM_TOTAL_TESTS = 100;
K = 3;

ERRS_ISC = test_N_classify(X_ISC, Y_ISC, PERCENT_TRAIN_SET, NUM_TOTAL_TESTS, K);
ERRS_PCA = test_N_classify(X_PCA, Y_PCA, PERCENT_TRAIN_SET, NUM_TOTAL_TESTS, K);
ERRS_rand = test_N_classify(X_rand, Y_rand, PERCENT_TRAIN_SET, NUM_TOTAL_TESTS, K);


%% PLOTS!
if plots
    plot(ERRS_ISC);
    hold on;
    plot(ERRS_PCA, 'Color', [0.8 0 0]);
    plot(ERRS_rand, 'Color', [0 0.8 0]);
    mISC = mean(ERRS_ISC);
    mPCA = mean(ERRS_PCA);
    mrand = mean(ERRS_rand);
    V = axis;
    line(V(1:2), [mISC mISC], 'LineStyle', '--', 'Color', [0 0 1]);
    line(V(1:2), [mPCA mPCA], 'LineStyle', '--', 'Color', [0.8 0 0]);
    line(V(1:2), [mrand mrand], 'LineStyle', '--', 'Color', [0 0.8 0]);
    hold off;
    legend('ISC', 'PCA', 'random');
    title(sprintf('CLASSIFICATION ERROR FOR %d TESTS', NUM_TOTAL_TESTS));
    xlabel('test num');
    ylabel('percent error');
end
