function [] = plot_imgs_rescale(IMGS, title, max_window, title_mm)
    if nargin < 3
        max_window = length(IMGS);
    end
    if nargin < 4
        title_mm = true;
    end
    mins = cellfun(@(b) min(min(b)), IMGS);
    maxs = cellfun(@(b) max(max(b)), IMGS);
    shift = -min(mins);
    scale = 1/(max(maxs)+shift);
    rescaled = cellfun(@(b) (b+shift)*scale, IMGS, 'UniformOutput', false);
    titles = arrayfun(@(i) ['min=' num2str(mins(i)) ' max=' num2str(maxs(i))], 1:length(IMGS), 'UniformOutput', false);
    hs = plot_m_n_imgs(rescaled, titles, max_window, title_mm);
    for h=1:length(hs)
        figure(hs(h));
        suplabel(sprintf('%s :: group %d of %d', title, h, length(hs)),'t');
%         suplabel('pitch', 'x');
%         suplabel('time', 'y');
    end
end