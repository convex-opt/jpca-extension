function plotObjectiveValues(fits)

%     nfs = numel(fits);
    nms = {fits.name}; % fit names
    vs = {fits.stats}; % obj values for each iteration
    vsNms = fieldnames(fits(1).stats);
    
    % set size of plot
    nfs = numel(nms);
    nd = numel(vsNms);
    nrows = floor(sqrt(nd)); ncols = ceil(nd / nrows);

    % total objective, reconstruction error, and fit of latent dynamics
    figure; set(gcf, 'color', 'w');
    for ii = 1:nd
        subplot(nrows, ncols, ii); hold on;
        for jj = 1:nfs
            vscur = [vs{jj}.(vsNms{ii})];
            plot(vscur);
        end
        xlabel('iter #');
        ylabel([vsNms{ii} ' objective value']);
        box off;
    end

end
