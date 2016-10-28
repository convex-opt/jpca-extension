function plotObjectiveValues(fits)

    nms = {fits.name}; % fit names
    vs = {fits.objValues}; % obj values for each iteration
    vsNms = {'Full', 'DimRed', 'RotDyn'};
    
    % set size of plot
    nnms = numel(nms);
    nd = size(vs{1},2);
    nrows = floor(sqrt(nd)); ncols = ceil(nd / nrows);

    % total objective, reconstruction error, and fit of latent dynamics
    figure; set(gcf, 'color', 'w');
    for ii = 1:nd
        subplot(nrows, ncols, ii); hold on;
        for jj = 1:numel(nnms)
            vscur = vs{jj};
            plot(vscur(:,ii));
        end
        xlabel('iter #');
        ylabel([vsNms{ii} ' objective value']);
        box off;
    end

end
