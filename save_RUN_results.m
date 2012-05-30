fprintf('SAVING to\n');

fname = sprintf('%d_train__V2__%d_harmony__%d_feat_size_%d__%d_ISC_iter__%f_lambda__%f_sigma_', length(TRAIN_WINDOWS), N_HARMONY, N_FEATURES, WINDOW_WIDTH, outer, lambda, sigma);
fnames = dir('saved data/remote');
fnames = fnames(~[fnames.isdir]);
count_fname = 0;

for i=1:length(fnames)
    f = fnames(i);
    if any(strfind(f.name, fname) == 1)
        count_fname = count_fname + 1;
    end
end

fname_full = [fname num2str(count_fname) '.mat'];
save(fullfile('saved data', 'remote', fname_full));

fprintf('\t%s\n', fname_full);