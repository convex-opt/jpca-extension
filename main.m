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

params = struct('numPCs', 4);
times = -50:10:150;
neurInds = 1:2:218; % just use every other neuron, for memory's sake
trainPct = 80;
[D, TrainSet, TestSet] = tools.loadAndInitNeuralData(params, ...
    times, neurInds, trainPct);

%% solve

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

lmb_vals = [0.0005 0.001 0.005];
% lmb_vals = 0.001;

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

figure; set(gcf, 'color', 'w');
nrows = 1; ncols = 2;
flds = {'varExplained_dimred', 'rsq_dynamics'};
dspNms = {'dimred', 'latdyn'};
subplot(nrows, ncols, 1); hold on;
tools.plotjCABvsjPCA(outputs, flds, dspNms);
ylim([0 100]);
subplot(nrows, ncols, 2); hold on;
tools.plotjCABvsjPCA(outputs, flds, dspNms, 'test_stats');
ylim([0 100]);
tools.setPrintSize(gcf, 10, 6, 0);

% tools.plotObjectiveValues(outputs);

%% plot in jPCA style

CurSet = TrainSet; % TestSet
Projection = CurSet.Projection;
Summary = CurSet.Summary;

Ah = outputs(1).Ah; % jCAB
Bh = outputs(1).Bh; % jCAB

% Ah = iters.Ah{1}; % jPCA
% Bh = iters.Bh{1}; % jPCA

% Ah = Summary.PCs;
% Bh = Summary.Mskew; % jPCA
% Bh = Summary.Mbest; % jPCA

Ared = Summary.Ared;
numAnalyzedTimes = size(Ared,1)/numel(Projection);
Bh = jPCA.getjPCsFromMskew(Bh, Ared, numAnalyzedTimes);

Proj = [];
for ii = 1:numel(Projection)
    
    X = Projection(ii).smallA;
    X = bsxfun(@minus, X, mean(D.X));
    Proj(ii).tradPCAproj = X*Ah;
    Proj(ii).proj = Proj(ii).tradPCAproj*Bh;
    Proj(ii).times = Projection(ii).times;
    
    X = Projection(ii).bigA;
    X = bsxfun(@minus, X, mean(D.X));
    Proj(ii).tradPCAprojAllTimes = X*Ah;
    Proj(ii).projAllTimes = Proj(ii).tradPCAprojAllTimes*Bh;
    Proj(ii).allTimes = Projection(ii).allTimes;

end

Summ.varCaptEachPC = D.k:-1:1; % just something in reverse order
Summ.varCaptEachPlane = 1:(D.k/2); % must be even
Summ.crossCondMean = [];

prms = struct();
prms.planes2plot = 1;
prms.substRawPCs = false;
prms.times = Proj(1).times; % e.g., -50:10:150

[colorStruct, haxP, vaxP] = jPCA.phaseSpace(Proj, Summ, prms);

%%

clear Outputs;
for ii = 1:numel(iters.Ah)
    Outputs(ii).Ah = iters.Ah{ii};
    Outputs(ii).Bh = iters.Bh{ii};
end

% jPCA.phaseMovie(Proj, Summ);
% tools.rotationMovie2(Proj, Summ, V, Proj(1).times, 70, 70);
tools.rotationMovie2(D, Projection, Summary, outputs, ...
    Projection(1).times)
