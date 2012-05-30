% test_song_loading.m
% try loading all songs, print out which failed.

helper_get_midi_names;

all_songs_cell = {};

for c=1:length(all_songs)
    for s=1:length(all_songs(c).songs)
        name = all_songs(c).songs{s};
        all_songs_cell = horzcat(all_songs_cell, {name});
    end
end

success = ones(length(all_songs_cell),1);

parfor s=1:length(all_songs_cell)
    name = all_songs_cell{s};
    fprintf('checking %s\n', name);
    S = load_and_format_midi(name);
    if isempty(S)
        success(s) = 0;
    end
end

clc;
fprintf('----------------\nSUCCESS\n');
for i=1:length(success);
    if success(i)
        fprintf('\t%s\n', all_songs_cell{i});
    end
end
fprintf('\nFAIL\n');
for i=1:length(success)
    if ~success(i)
        fprintf('\t%s\n', all_songs_cell{i});
    end
end