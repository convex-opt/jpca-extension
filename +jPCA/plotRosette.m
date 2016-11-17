function plotRosette(Proj, whichPair)
%% Plot the rosette itself (may need to spruce this up and move to a subfunction)

    d1 = 1 + 2*(whichPair-1);
    d2 = d1+1;

    numConds = length(Proj);

    figure;

    % first deal with the ellipse for the plan variance (we want this under the rest of the data)
    planData = zeros(numConds,2);
    for c = 1:numConds
        planData(c,:) = Proj(c).proj(1,[d1,d2]);
    end
    planVars = var(planData);
    circle([0 0], 2*planVars.^0.5, 0.6*[1 1 1], 1); hold on;
    %fprintf('ratio of plan variances = %1.3f (hor var / vert var)\n', planVars(1)/planVars(2));

    allD = vertcat(Proj(:).proj);  % just for getting axes
    allD = allD(:,d1:d2);
    mxVal = max(abs(allD(:)));
    axLim = mxVal*1.05*[-1 1 -1 1];
    arrowSize = 5;
    for c = 1:numConds
        plot(Proj(c).proj(:,d1), Proj(c).proj(:,d2), 'k');
        plot(Proj(c).proj(1,d1), Proj(c).proj(1,d2), 'ko', 'markerFaceColor', [0.7 0.9 0.9]);

        penultimatePoint = [Proj(c).proj(end-1,d1), Proj(c).proj(end-1,d2)];
        lastPoint = [Proj(c).proj(end,d1), Proj(c).proj(end,d2)];
        arrowMMC(penultimatePoint, lastPoint, [], arrowSize, axLim);

    end

    axis(axLim);
    axis square;
    plot(0,0,'k+');
    
    title(sprintf('jPCA plane %d', whichPair));
end
