function img = img_reconstruct(weights, basises)
    img = zeros(size(basises{1}));
    for i=1:length(basises)
        img = img + weights(i) * basises{i};
    end
end