% v = song_convolve(songmat2D, D, types)
%
% songmat2D : the song
% D         : the dictionary of convolutional features
% type      : 'mean', 'hcsm', 'max', 'sum' : cell array of functions to apply to
%               the convolution result.
%
% v = resulting feature vector, size len(D)*len(types)

function v = song_convolve(songmat2D, D, types)
    if nargin < 3
        types = {'mean', 'hcsm'};
    end
    
    [winrows, wincols] = size(D{1});
    [srows, scols] = size(songmat2D);
    
    v = zeros(length(D)*length(types), 1);
    
    song_nonzero_inds = find(songmat2D(1:srows-winrows+1, 1:scols-wincols+1) > 1E-4);
    fprintf('songsize: %d by %d\n', size(songmat2D,1), size(songmat2D,2));
    fprintf('num nonzero inds = %d\n', length(song_nonzero_inds));
    fprintf('num elements in song = %d\n', numel(songmat2D));
    
    if isempty(song_nonzero_inds)
        v = [];
        return
    end
    
    conv_results = zeros(length(song_nonzero_inds), length(D));
    
    % perform convolutions
    for i=1:length(D)
        feat = D{i};
%         fprintf('feature %d\n', i);
        for s=1:length(song_nonzero_inds)
            [top left] = ind2sub([srows-winrows+1, scols-wincols+1], song_nonzero_inds(s));
            window = songmat2D(top:top+winrows-1, left:left+wincols-1);
            conv_results(s,i) = sum(sum(feat .* window));
        end
    end
    
    % convert convolution results to actual features
    ntypes = length(types);
    for i=1:length(v)
        t = mod((i-1),ntypes)+1;
        c = floor((i-1)/ntypes)+1;
        typ = types{t};
        data = conv_results(c,:);
        switch lower(typ)
            case 'mean'
                v(i) = mean(data);
            case 'max'
                v(i) = max(data);
            case 'sum'
                v(i) = sum(data);
            case 'hcsm'
                data_m = data - mean(data);
                data_m = max(0, data_m);
                v(i) = sum(data_m.^2) / sum(data_m);
            otherwise
                % nothing..
        end
    end
end