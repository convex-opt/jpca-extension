function [X, Xd, jPCA_data] = preprocessNeuralData(Data, analyzeTimes, params)
    % reproduce preprocessing done by jPCA, and return starting point for
    % jPCA

    % quick bookkeeping

    numConds = length(Data);
    numTimes = size(Data(1).A,1);
    % there is also a 'numAnalyzedTimes' defined below.

    %% setting parameters that may or may not have been specified

    % 'times' field
    % if the user didn't specify a times field, create one that starts with '1'
    if ~isfield(Data(1),'times')
        for c = 1:length(Data)
            Data(c).times = 1:numTimes;
        end
    end

    if exist('analyzeTimes', 'var') && ~isempty(analyzeTimes) && max(diff(analyzeTimes)) > max(diff(Data(1).times))
        disp('error, you can use a subset of times but you may not skip times within that subset');
        Projection = []; Summary = []; return;
    end

    % the number of PCs to look within
    numPCs = 6;
    if exist('params', 'var') && isfield(params,'numPCs')
        numPCs = params.numPCs;
    end
    if rem(numPCs,2)>0
        disp('you MUST ask for an even number of PCs.'); return;
    end

    % do we normalize
    normalize = true;
    if exist('params', 'var') && isfield(params,'normalize')
        normalize = params.normalize;
    end

    % do we soften the normalization (so weak signals stay smallish)
    % numbers larger than zero mean soften the norm.
    % The default (10) means that 10 spikes a second gets mapped to 0.5, infinity to 1, and zero to zero.
    % Beware if you are using data that isn't in terms of spikes/s, as 10 may be a terrible default
    softenNorm = 10;
    if exist('params', 'var') && isfield(params,'softenNorm')
        softenNorm = params.softenNorm;
    end

    % do we mean subtract
    meanSubtract = true;
    if exist('params', 'var') && isfield(params,'meanSubtract')
        meanSubtract = params.meanSubtract;
    end
    if length(Data)==1, meanSubtract = false; end  % cant mean subtract if there is only one condition

    if ~exist('analyzeTimes', 'var') || isempty(analyzeTimes)
        disp('analyzing all times');
        analyzeTimes = Data(1).times;
    end

    %% figure out which times to analyze and make masks
    %
    analyzeIndices = ismember(round(Data(1).times), analyzeTimes);
    if size(analyzeIndices,1) == 1
        analyzeIndices = analyzeIndices';  % orientation matters for the repmat below
    end
    analyzeMask = repmat(analyzeIndices,numConds,1);  % used to mask bigA
    if diff( Data(1).times(analyzeIndices) ) <= 5
        disp('mild warning!!!!: you are using a short time base which might make the computation of the derivative a bit less reliable');
    end

    % these are used to take the derivative
    bunchOtruth = true(sum(analyzeIndices)-1,1);
    maskT1 = repmat( [bunchOtruth;false],numConds,1);  % skip the last time for each condition
    maskT2 = repmat( [false;bunchOtruth],numConds,1);  % skip the first time for each condition

    if sum(analyzeIndices) < 5
        disp('warning, analyzing few or no times');
        disp('if this wasnt your intent, check to be sure that you are asking for times that really exist');
    end

    %% make a version of A that has all the data from all the conditions.
    % in doing so, mean subtract and normalize

    bigA = vertcat(Data.A);  % append conditions vertically

    % note that normalization is done based on ALL the supplied data, not just what will be analyzed
    if normalize  % normalize (incompletely unless asked otherwise)
        ranges = range(bigA);  % For each neuron, the firing rate range across all conditions and times.
        normFactors = (ranges+softenNorm);
        bigA = bsxfun(@times, bigA, 1./normFactors);  % normalize
    else
        normFactors = ones(1,size(bigA,2));
    end

    sumA = 0;
    for c = 1:numConds
        sumA = sumA + bsxfun(@times, Data(c).A, 1./normFactors);  % using the same normalization as above
    end
    meanA = sumA/numConds;
    if meanSubtract  % subtract off the across-condition mean from each neurons response
        bigA = bigA-repmat(meanA,numConds,1);
    end

    %% now do traditional PCA

    smallA = bigA(analyzeMask,:);
    Xd = smallA(maskT2,:) - smallA(maskT1,:);  % the masks just give us earlier and later times within each condition
    X = smallA(maskT1,:);  % just for convenience, keep the earlier time in its own variable

    %% jPCA:
    [Ah,rawScores] = princomp(smallA,'econ');  % apply PCA to the analyzed times
    Ared = rawScores(:,1:numPCs);  % cut down to the right number of PCs
    Zd = Ared(maskT2,:) - Ared(maskT1,:);  % the masks just give us earlier and later times within each condition
    Z = Ared(maskT1,:);
    M = (dState'/preState');  % M takes the state and provides a fit to dState
    Mskew = skewSymRegress(dState,preState)';
    jPCA_data.Ah = Ah;
    jPCA_data.Zd = Zd;
    jPCA_data.Z = Z;
    jPCA_data.M = M;
    jPCA_data.Mskew = Mskew;

end
