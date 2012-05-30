function song_features = construct_features(songs_cell, D, types)
    if nargin < 4
        types = {'mean', 'hcsm'}; % {'mean', 'hcsm', 'max', 'sum'};
    end
    
    song_features = cell(length(songs_cell),1);
    %song_features = zeros(length(D)*length(types), length(songs_cell));
    
    parfor s=1:length(songs_cell)
        fprintf('getting features for %d\n', s);
        song_features{s} = song_convolve(songs_cell{s}, D, types);
    end
end