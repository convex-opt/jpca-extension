%% cd to this dir, and set up paths

% tmp = matlab.desktop.editor.getActive;
% cd(fileparts(tmp.Filename));
setpaths; % add jPCA and manopt paths

%% OPTION 1: load simulated data

rng(1334); % set rand seed
n = 200; % # trials
k = 2; % latent dimensionality
p = 3; % observation dimensionality
rotOnly = true; % rotations only
D = tools.simulateData(n, k, p, 0.5, 10, 0.5, rotOnly, pi/3); % data struct
% tools.plotLatentsAndObservations(D.Z, D.X);

%% OPTION 2: load neural data (use jPCA to preprocess)

data = load('data/exampleData.mat');
Data = data.Data; clear data;

params = struct();
params.numPCs = 4; % latent dimensionality
params.normalize = true; % across time and conditions
params.softenNorm = true; % ignored if not normalizing
params.meanSubtract = true; % does across-condition mean
params.suppressBWrosettes = false; % don't plot
params.suppressHistograms = true; % don't plot
params.suppressText = false;
times = -50:10:150;

trainInds = false(numel(Data),1); trainInds(1:80) = true;
[Projection, Summary] = jPCA.jPCA(Data(trainInds), times, params);
X0 = Summary.smallA;
t1 = Summary.maskT1;
t2 = Summary.maskT2;
clear D;
D.dX = X0(t2,:) - X0(t1,:);
D.X = X0(t1,:);
D.k = params.numPCs;

[Projection2, Summary2] = jPCA.jPCA(Data(~trainInds), times, params);
X0 = Summary2.smallA;
t1 = Summary2.maskT1;
t2 = Summary2.maskT2;
D.dXtest = X0(t2,:) - X0(t1,:);
D.Xtest = X0(t1,:);

neurInds = 1:2:size(D.X,2);
% neurInds = 1:150;
D.X = D.X(:,neurInds);
D.dX = D.dX(:,neurInds);
D.Xtest = D.Xtest(:,neurInds);
D.dXtest = D.dXtest(:,neurInds);

%% solve

D.k = 4;
outputs = [];

methodName_A = 'stiefel'; % 'projGrad', 'stiefel', 'oblique', or 'simple'
methodName_B = 'linreg'; % 'sym', 'antisym', or 'linreg'
opts = struct('methodName_A', methodName_A, ...
    'methodName_B', methodName_B, ...
    'lambda', 1.0, 'maxiters', 500, ...
    'nLatentDims', D.k, ...
    'verbosity', 1, ...
    'enforceOrthonormal_A', true, ...
    'tol', 1e-3);

lmb_vals = [0.0001 0.001 0.01];

for lm = lmb_vals
    opts.lambda = lm;
    [Ah, Bh, Ch, iters, stats] = jCAB.jCAB(D.X, D.dX, opts);

    % save fit
    clear output;
    output.name = [methodName_A '_' methodName_B];
    output.Ah = Ah;
    output.Bh = Bh;
    output.Ch = Ch;
    output.opts = opts;
    output.stats = stats;
    
    % print and add summary    
    output.test_stats(1) = tools.fitStats(D.Xtest, D.dXtest, ...
        iters.Ah{1}, iters.Bh{1}, iters.Ch{1}, opts);
    output.test_stats(2) = tools.fitStats(D.Xtest, D.dXtest, ...
        Ah, Bh, Ch, opts);
    output.summary = tools.printSummaryStats(output);
    outputs = [outputs; output];
        
end

figure; set(gcf, 'color', 'w'); title(['snr: ' num2str(goal_snr)]);
nrows = 1; ncols = 2;
flds = {'varExplained_dimred', 'rsq_dynamics'};
dspNms = {'dimred', 'latdyn'};
subplot(nrows,ncols,1); hold on;
tools.plotjCABvsjPCA(outputs, flds, dspNms);
ylim([0 100]);
subplot(nrows,ncols,2); hold on;
tools.plotjCABvsjPCA(outputs, flds, dspNms, 'test_stats');
ylim([0 100]);

tools.setPrintSize(gcf, 10, 6, 0);

%% compare objective values

tools.plotObjectiveValues(outputs);

%% plot in jPCA style

% must also have neurInds
% Ah = outputs(1).Ah; % jCAB
Ah = iters.Ah{1}; % jPCA
Bh = iters.Bh{1}; % jPCA
Bh = Summary.Mskew; % jPCA

Ared = Summary.Ared;
numAnalyzedTimes = size(Ared,1)/numel(Projection);
Bh = jPCA.getjPCsFromMskew(Bh, Ared, numAnalyzedTimes);
% Bh = eye(size(Ah,2));
Bh = Summary.jPCs;

Proj = [];
for ii = 1:numel(Projection)
    X = Projection(ii).smallA(:,neurInds);
    Proj(ii).proj = bsxfun(@minus, X, mean(D.X))*(Ah*Bh);
    Proj(ii).times = times';
    
    % copy over just to match original form
    Proj(ii).projAllTimes = Proj(ii).proj;
    Proj(ii).allTimes = Proj(ii).times;
    Proj(ii).tradPCAproj = Proj(ii).proj;
    Proj(ii).tradPCAprojAllTimes = Proj(ii).proj;    
end

Summ.varCaptEachPC = D.k:-1:1; % just something in reverse order
Summ.varCaptEachPlane = 1:(D.k/2); % must be even
Summ.crossCondMean = [];
prms = struct();
prms.planes2plot = 1;
prms.substRawPCs = true;
[colorStruct, haxP, vaxP] = jPCA.phaseSpace(Proj, Summ, prms);
