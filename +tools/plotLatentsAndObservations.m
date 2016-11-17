function plotLatentsAndObservations(Z, X)

    figure; set(gcf, 'color', 'w');
    clrs = summer(size(Z,1)); % color code for time

    % plot latents
    subplot(1,2,1); hold on;
    for ii = 2:size(Z,1)
        plot(Z(ii-1:ii,1), Z(ii-1:ii,2), '-', 'Color', clrs(ii,:));
    end
    title(['latents (' num2str(size(Z,2)) 'd)']);

    % plot observations
    subplot(1,2,2); hold on;
    for ii = 2:size(X,1)
        plot3(X(ii-1:ii,1), X(ii-1:ii,2), X(ii-1:ii,3), '-', ...
            'Color', clrs(ii,:));
    end
    title(['observations (' num2str(size(X,2)) 'd)']);

end
