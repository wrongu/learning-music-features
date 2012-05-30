if ~exist('composers', 'var')
    composers = {'joplin', 'chopin'};
end

if ~exist('loadable_midis', 'var')
    get_loadable_midis;
end

if ~exist('song2d_cell', 'var')

    all_song_paths = {};
    all_composers = {};
    for i=1:length(all_songs)
        if any(ismember(composers, all_songs(i).composer))
    %         disp(all_songs(i).songs{1});
            all_song_paths = horzcat(all_song_paths, all_songs(i).songs);
            nsongs = length(all_songs(i).songs);
            for j=1:nsongs
                all_composers = horzcat(all_composers, {all_songs(i).composer});
            end
        end
    end
    
    
    nsong_prev = length(all_song_paths);
    song2d_cell = cell(nsong_prev,1);
    parfor s=1:nsong_prev
        fprintf('%d of %d:\t', s, nsong_prev);
        try
           songpath = all_song_paths{s};
           if any(ismember(loadable_midis, songpath))
               song2d_cell{s} = load_and_format_midi(songpath);
           else
               song2d_cell{s} = [];
           end
        catch e
           song2d_cell{s} = [];
        end
    end
%     song2d_cell = cellfun(@(song) load_and_format_midi(song), all_song_paths, 'UniformOutput', false);
end

nsong_prev = length(song2d_cell);
nonempty = cellfun(@(s) ~isempty(s), song2d_cell);
song2d_cell = song2d_cell(nonempty);
all_composers = all_composers(nonempty);

if nsong_prev < length(song2d_cell)
    fprintf('midi lib failed. %d songs remain of %d originally\n', length(song2d_cell), nsong_prev);
end