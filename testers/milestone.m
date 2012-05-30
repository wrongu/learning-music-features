% milestone: run iterative_sparse_encoding on some songs
%
% Richard Lange

%% INIT AND LOAD

clc;
close all;

init;

composers = {'joplin'};
get_song_matrices;

n_songs = length(song2d_cell);

SAMPLE_SIZE = 12;
SAMPLES_PER_SONG = 15;
N_FEATURES = SAMPLE_SIZE^2;

N_HARMONY = 2;

%% HARMONY BOOST

harmonies = cellfun(@(song2D) harmony_boost(song2D, N_HARMONY), song2d_cell, 'UniformOutput', false);


%% WINDOWS

windows_by_song = cellfun(@(song2D) get_song_windows(song2D, SAMPLES_PER_SONG, SAMPLE_SIZE, true, 0), harmonies, 'UniformOutput', false);
all_windows = vertcat(windows_by_song{:});

%% TRAINING

lambda = 1;
sigma = 1;
%
%
%
if parallel
    [A, B, b_hist, mean_err] = par_iterative_sparse_encoding(all_windows, N_FEATURES, lambda, sigma, 500, 60, 2, 0.001);
else
    [A, B, b_hist, mean_err] = iterative_sparse_encoding(all_windows, N_FEATURES, lambda, sigma, 500, 60, 2, 0.001);
end
%
%
%

%% PLOT ERROR CONVERGENCE
figure();
subplot(1,2,1);
plot(mean_err, '-o');
xlabel('outer iteration');
ylabel('mean error for all imgs');
title('Error vs. Iteration');
subplot(1,2,2);
plot(b_hist, '-o');
xlabel('outer iteration');
ylabel('L-inf norm of delta-PHI');
title('delta-PHI vs. Iteration');

%% PLOT TRAIN DATA

plot_imgs_rescale(all_windows, 'ALL TRAINING WINDOWS', 49, false);

%% PLOT RECONSTRUCTED

reconstructed = arrayfun(@(k) img_reconstruct(A(k,:), B), 1:length(all_windows), 'UniformOutput', false);
plot_imgs_rescale(reconstructed, 'RECONSTRUCTED IMAGES', 49, false);

%% PLOT FEATURES

plot_imgs_rescale(B, 'LEARNED FEATURES', 25, false);