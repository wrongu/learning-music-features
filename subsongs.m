function subs = subsongs(song, maxlen)
    subs = cell(floor(size(song,1)/maxlen),1);
    ind = 1;
    i = 1;
    j = i+maxlen-1;
    while j <= size(song,1)
        subs{ind} = song(i:j,:);
        ind = ind+1;
        i = j+1;
        j = i+maxlen-1;
    end
end