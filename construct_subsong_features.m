function [X Y] = construct_subsong_features(songs_cell, all_composers, EXAMPLE_LENGTH, D)
    Y = {};
    X = {};
    for s=1:length(songs_cell)
        fprintf('---------------------\n--   big song %2d   --\n---------------------\n', s);
        X_NEW = construct_features(subsongs(songs_cell{s}, EXAMPLE_LENGTH), D, EXAMPLE_LENGTH);
        X_NEW = X_NEW(cellfun(@(feat) ~isempty(feat), X_NEW));
        Y = vertcat(Y, repmat(all_composers(s), length(X_NEW), 1));
        X = vertcat(X, X_NEW);
    end
    X = horzcat(X{:})';
end