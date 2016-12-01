function plotObjectiveValues(fits)

    nms = {fits.name}; % fit names
    vs = {fits.stats}; % obj values for each iteration
    vsNms = {'objValue_full', 'objValue_dimred', 'objValue_latdyn', ...
        'rsq_dynamics'};
    vsNms = fieldnames(fits.stats);
    
    % set size of plot
    nnms = numel(nms);
    nd = numel(vsNms);
    nrows = floor(sqrt(nd)); ncols = ceil(nd / nrows);

    % total objective, reconstruction error, and fit of latent dynamics
    figure; set(gcf, 'color', 'w');
    for ii = 1:nd
        subplot(nrows, ncols, ii); hold on;
        for jj = 1:numel(nnms)
            vscur = [vs{jj}.(vsNms{ii})];
            plot(vscur);
        end
        xlabel('iter #');
        ylabel([vsNms{ii} ' objective value']);
        box off;
    end

end
