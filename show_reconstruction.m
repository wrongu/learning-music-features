% Show how a reconstructed image is built from features

i = ceil(rand*size(A,1));
num_feat = 3;

Ai = A(i,:);

Ameans = mean(abs(A),1);
[~,mean_inds] = sort(Ameans, 'descend');

recon = arrayfun(@(i) Ai(i)*B{i}, 1:length(Ai), 'UniformOutput', false);
recon = sum(cat(3, recon{:}), 3);

[~, inds] = sort(abs(Ai), 'descend');

plot_imgs_rescale({TRAIN_WINDOWS{i},recon}, 'Reconstruction', 2, false);
plot_imgs_rescale(B(inds(1:num_feat)), 'Features', num_feat, false);

for i=1:num_feat
    subplot(1,num_feat, i);
    title(sprintf('feature # %d', mean_inds(inds(i))));
    xlabel(sprintf('* %f', Ai(inds(i))));
end
