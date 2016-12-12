function [D, TrainSet, TestSet] = loadAndInitNeuralData(opts, ...
    times, neurInds, trainPct)
    if nargin < 1 || isempty(opts)
        opts = struct();
    end
    if nargin < 2 || isempty(times)
        times = -50:10:150;
    end
    if nargin < 3
        neurInds = [];
    end
    if nargin < 4
        trainPct = nan;
    end
    % set field to default value if field is not set
    defopts = struct('numPCs', 4, 'normalize', true, ...
        'softenNorm', true, 'meanSubtract', true, ...
        'suppressBWrosettes', true, 'suppressHistograms', true, ...
        'suppressText', false);    
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    data = load('data/exampleData.mat');
    Data = data.Data;
    
    % optional: ignore some neurons (for memory's sake)
    if ~isempty(neurInds)
        for ii = 1:numel(Data)
            Data(ii).A = Data(ii).A(:,neurInds);
        end
    end
    % optional: split data into train/test by condition
    trainInds = true(numel(Data),1);
    if ~isnan(trainPct) % pick random subset of inds to be test set
        inds = randperm(numel(Data));
        lastInd = ceil((trainPct/100)*numel(Data));
        trainInds(inds(lastInd+1:end)) = false;
        assert(abs(100*mean(trainInds)) - trainPct < 1, ...
            'error in train/test split');
    end
    
    % training data
    [Projection, Summary] = jPCA.jPCA(Data(trainInds), times, opts);
    X0 = Summary.smallA;
    t1 = Summary.maskT1;
    t2 = Summary.maskT2;
    D.dX = X0(t2,:) - X0(t1,:);
    D.X = X0(t1,:);
    D.k = opts.numPCs;
    TrainSet.Projection = Projection;
    TrainSet.Summary = Summary;

    % test data
    if sum(~trainInds) > 0
        [Projection2, Summary2] = jPCA.jPCA(Data(~trainInds), times, opts);
        TestSet.Projection = Projection2;
        TestSet.Summary = Summary2;
        X0 = Summary2.smallA;
        t1 = Summary2.maskT1;
        t2 = Summary2.maskT2;
        D.dXtest = X0(t2,:) - X0(t1,:);
        D.Xtest = X0(t1,:);
    else
        D.dXtest = [];
        D.Xtest = [];
        TestSet = struct();
    end

end
