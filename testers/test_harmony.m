init;

% song2d_cell = cellfun(@(song) load_and_format_midi(song), all_songs, 'UniformOutput', false);

% song1 = song2d_cell{1};
sname = all_songs(5).songs{1};
song1 = load_and_format_midi(sname);

harmony1 = harmony_boost(song1, 0)';
harmony1 = repmat(harmony1, [1 1 3]);
harmony2 = harmony_boost(song1, 1)';
harmony2 = repmat(harmony2, [1 1 3]);
harmony3 = harmony_boost(song1, 2)';
harmony3 = repmat(harmony3, [1 1 3]);

figure();
subplot(3,1,1);
image(harmony1(:, 1:100, :));
title('binary song');
subplot(3,1,2);
image(harmony2(:, 1:100, :));
title('1 iteration of harmony boosting');
subplot(3,1,3);
image(harmony3(:, 1:100, :));
title('2 iterations of harmony boosting');

suptitle('Testing harmony boosting');
