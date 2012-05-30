function h = plot_m_n_imgs(cellarray_imgs, titles, max_window, title_on)
    if nargin < 2
        titles = cell(size(cellarray_imgs));
    end
    if nargin < 3
        max_window = length(cellarray_imgs);
    end
    if nargin < 4
        title_on = true;
    end
    inds = 0:max_window:length(cellarray_imgs);
    if inds(end) ~= length(cellarray_imgs)
        inds = [inds length(cellarray_imgs)];
    end

    for j=1:length(inds)-1
        img_range = cellarray_imgs(inds(j)+1:inds(j+1));    
        h(j) = figure();
        N = length(img_range);
        m = floor(sqrt(N));
        n = ceil(N/m);
        for i=1:N
            subplot(m, n, i);
            image(repmat(img_range{i}, [1 1 3]));
            if title_on
                title(titles{i});
            end
            axis square;
            set(gca, 'XTickLabel', {}, 'YTickLabel', {});
        end
    end
end