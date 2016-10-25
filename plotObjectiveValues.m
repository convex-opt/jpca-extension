function plotObjectiveValues(vs, angs)
    
    % set size of plot
    fnms = fieldnames(vs);
    nvs = size(vs.(fnms{1}),2);
    nas = size(angs.(fnms{1}),2);
    nd = nvs + nas;
    ncols = floor(sqrt(nd)); nrows = ceil(nd / ncols);

    % total objective, reconstruction error, and fit of latent dynamics
    vsNms = {'Full', 'DimRed', 'RotDyn'};
    figure; set(gcf, 'color', 'w');
    for ii = 1:nvs
        subplot(nrows, ncols, ii); hold on;
        for jj = 1:numel(fnms)
            cur_vs = vs.(fnms{jj});
            plot(log(cur_vs(:,ii)));
        end
        xlabel('iter #');
        ylabel([vsNms{ii} ' objective value']);
        box off;
    end

    % angle between A and Ah, and B and Bh
    angNms = {'angle(B, Bh)', 'angle(A, Ah)'};
    for ii = 1:nas
        subplot(nrows, ncols, ii+nvs); hold on;
        for jj = 1:numel(fnms)
            cur_angs = angs.(fnms{jj});
            plot(cur_angs(:,ii));
        end
        xlabel('iter #'); ylabel(angNms{ii});
        box off;
        ylim([0 90]);
        set(gca, 'YTick', 0:30:90);
        set(gca, 'YTickLabel', arrayfun(@num2str, 0:30:90, 'uni', 0));
    end
    legend(fnms);

end
