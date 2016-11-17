function circStatsSummary = plotPhaseDiff(phaseData, params, jPCplane)
%% plotting the phase difference between dx(t)/dt and x(t) where x is the 2D state

    % compute the circular mean of the data, weighted by the r's
    circMn = circ_mean([phaseData.phaseDiff]', [phaseData.radius]');
    resultantVect = circ_r([phaseData.phaseDiff]', [phaseData.radius]');
    
    
    bins = pi*(-1:0.1:1);
    cnts = histc([phaseData.phaseDiff], bins);  % not for plotting, but for passing back out
    

    % do this unless params contains a field 'suppressHistograms' that is true
    if ~exist('params', 'var') || ~isfield(params,'suppressHistograms') || ~params.suppressHistograms
        figure;
        hist([phaseData.phaseDiff], bins); hold on;
        plot(circMn, 20, 'ro', 'markerFa', 'r', 'markerSiz', 8);
        plot(pi/2*[-1 1], [0 0], 'ko', 'markerFa', 'r', 'markerSiz', 8);
        set(gca,'XLim',pi*[-1 1]);
        title(sprintf('jPCs plane %d', jPCplane));
    end
    
    %fprintf('(pi/2 is %1.2f) The circular mean (weighted) is %1.2f\n', pi/2, circMn);
    
    % compute the average dot product of each datum (the angle difference for one time and condition)
    % with pi/2.  Will be one for perfect rotations, and zero for random data or expansions /
    % contractions.
    avgDP = jPCA.averageDotProduct([phaseData.phaseDiff]', pi/2);
    %fprintf('the average dot product with pi/2 is %1.4f  <<---------------\n', avgDP);
    
    circStatsSummary.circMn = circMn;
    circStatsSummary.resultantVect = resultantVect;
    circStatsSummary.avgDPwithPiOver2 = avgDP;  % note this basically cant be <0 and definitely cant be >1
    circStatsSummary.DISTRIBUTION.bins = bins;
    circStatsSummary.DISTRIBUTION.binCenters = (bins(1:end-1) + bins(2:end))/2;
    circStatsSummary.DISTRIBUTION.counts = cnts(1:end-1);
    circStatsSummary.RAW.rawData = [phaseData.phaseDiff]';
    circStatsSummary.RAW.rawRadii = [phaseData.radius]';
    
end
