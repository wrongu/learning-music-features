% windows = get_song_windows(song, nwindows, dim, israndom)
%
% return cell array of nwindows matrices of size dim*dim taken as samples 
%   from the song
%
% if windowstep is 0, does random
%
% Richard Lange :: CS 74 :: 12S

function windows = get_song_windows(songmat2D, n_windows, dim, only_nonzero)
    windows = cell(n_windows, 1);
    
    if nargin < 3
        dim = 12;
    end
    if nargin < 4
        only_nonzero = true;
    end
%     if nargin < 5
%         windowstep = dim;
%     end
    
    [songlength pitch_range] = size(songmat2D);
    max_beat_ind = songlength-dim;
    max_note_ind = 88-dim;
    
    if ~only_nonzero
        % Random
        for i=1:n_windows
            beat_ind = floor(rand * max_beat_ind) + 1;
            note_ind = floor(rand * max_note_ind) + 1;
            window = songmat2D(beat_ind:beat_ind+dim-1, note_ind:note_ind+dim-1);
            while only_nonzero && ~mat_nonzero(window)
                beat_ind = floor(rand * max_beat_ind) + 1;
                note_ind = floor(rand * max_note_ind) + 1;
                window = songmat2D(beat_ind:beat_ind+dim-1, note_ind:note_ind+dim-1);
            end
            windows{i} = window;
        end
    else
        % get windows that have notes in upper left corner
        indexable_range = songmat2D(1:songlength-dim+1, 1:pitch_range-dim+1);
        note_inds = find(indexable_range==1);
        max_n_windows = length(note_inds);
        rand_inds = randperm(max_n_windows);
        for i=1:min(max_n_windows, n_windows)
            [top left] = ind2sub(size(indexable_range), note_inds(rand_inds(i)));
            windows{i} = songmat2D(top:top+dim-1, left:left+dim-1);
        end
%         beat_ind = 1;
%         note_ind = 1;
%         for i=1:n_windows
%             window = songmat2D(beat_ind:beat_ind+dim, note_ind:note_ind+dim);
%             while only_nonzero && ~mat_nonzero(window)
%                 % step indices by windowstep
%                 if note_ind < max_note_ind
%                     note_ind = note_ind + windowstep;
%                 else
%                     note_ind = 1;
%                     if beat_ind < max_beat_ind
%                         beat_ind = beat_ind + windowstep;
%                     else
%                         windows = windows{1:i};
%                         break;
%                     end
%                 end
%                 window = songmat2D(beat_ind:beat_ind+dim, note_ind:note_ind+dim);
%             end
%             windows{i} = window;
%             % step indices by windowstep
%             if note_ind < max_note_ind
%                 note_ind = note_ind + windowstep;
%             else
%                 note_ind = 1;
%                 if beat_ind < max_beat_ind
%                     beat_ind = beat_ind + windowstep;
%                 else
%                     windows = windows{1:i};
%                     break;
%                 end
%             end
%         end
    end
end

function nz =  mat_nonzero(A)
    nz = any(any(A));
end