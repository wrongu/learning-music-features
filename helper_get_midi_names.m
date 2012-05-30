all_songs = struct('composer', [], 'songs', {});

rootdir = 'midi files';
subdirs = dir(rootdir);
subdirs = subdirs(3:end);
subdirs = subdirs([subdirs.isdir]);

for s=1:length(subdirs)
    c_dur = subdirs(s);
    compname = c_dur.name;
    subsub = fullfile(rootdir, compname);
    files = dir(subsub);
    files = files(3:end);
    all_songs(s).composer = compname;
    for i=1:length(files)
        all_songs(s).songs{i} = fullfile(subsub,files(i).name);
    end
end