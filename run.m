%% wrapper for executing the algorithm

init;
clc;
close all;


if ~exist('composers', 'var')
    composers = {'joplin', 'chopin'};
end
get_song_matrices;

if(~exist('parallel', 'var'))
    parallel = false;
end
if(~exist('pool', 'var'))
    pool = 2;
end

if parallel && pool > 0
    curpool = matlabpool('size');
    if curpool && curpool ~= pool
        matlabpool('close');
    elseif ~curpool
        eval(sprintf('matlabpool(%d)', pool));
    end
end

N_SONGS = length(song2d_cell);

if ~exist('N_TRAIN_WINDOWS', 'var')
    N_TRAIN_WINDOWS = 400;
end

N_WINDOWS_PER_SONG = floor(N_TRAIN_WINDOWS / length(song2d_cell));

if ~exist('N_FEATURES', 'var')
    N_FEATURES = 25;
end

if ~exist('N_HARMONY', 'var')
    N_HARMONY = 0;
end

WINDOW_WIDTH = 12;

TRAIN_SET       = song2d_cell;
NONZERO_TRAIN   = true;

plots = false;

%% APPLY HARMONY BOOST

disp('harmony boosing');
harmonies = cellfun(@(songmat) harmony_boost(songmat, N_HARMONY), TRAIN_SET, 'UniformOutput', false);

%% DIVIDE INTO WINDOWS

disp('gettin training samples');
% get random sampling dim x dim windows for training
TRAIN_WINDOWS = cellfun(@(songmat) get_song_windows(songmat, N_WINDOWS_PER_SONG, WINDOW_WIDTH, NONZERO_TRAIN), TRAIN_SET, 'UniformOutput', false);
% concatenate cell-array of cell-arrays of matrices to cell-array of
%   matrices
TRAIN_WINDOWS = vertcat(TRAIN_WINDOWS{:});

%% PLOT TRAIN DATA

if plots
    plot_imgs_rescale(TRAIN_WINDOWS, 'ALL TRAINING WINDOWS', 49, false);
end

%% RUN PCA

run_PCA;

%% RUN ISC

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

save_RUN_results;