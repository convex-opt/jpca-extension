%% cd to this dir; add paths

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))
setpaths; % add jPCA paths
% cd ../manopt; importmanopt; cd ../code;

%% OPTION 1: load simulated data

rng(1334); % set rand seed
n = 200; % # trials
k = 4; % latent dimensionality
p = 10; % observation dimensionality
rotOnly = true; % rotations only
D = simulateData(n, k, p, 0.5, 3.5, rotOnly, pi/3); % data struct

plotLatentsAndObservations(D.Z, D.X);

%% OPTION 2: load neural data (use jPCA to preprocess)

D = load('data/exampleData.mat');
Data = D.Data; clear D;

params = struct();
params.numPCs = 6; % latent dimensionality
params.normalize = true; % across time and conditions
params.softenNorm = true; % ignored if not normalizing
params.meanSubtract = true; % does across-condition mean
params.suppressBWrosettes = true; % don't plot
params.suppressHistograms = true; % don't plot
params.suppressText = false;

[Projection, Summary] = jPCA.jPCA(Data, [], params);

X0 = Summary.smallA;
t1 = Summary.maskT1;
t2 = Summary.maskT2;
D.dX = X0(t2,:) - X0(t1,:);
D.X = X0(t1,:);

%% solve

methodName_A = 'stiefel'; % 'projGrad', 'stiefel', or 'simple'
methodName_B = 'linreg'; % 'sym', 'antisym', or 'linreg'
opts = struct('methodName_A', methodName_A, ...
    'methodName_B', methodName_B, ...
    'lambda', 1.0, 'maxiters', 0, ...
    'nLatentDims', params.numPCs);

opts.Ah = Ah; opts.Bh = Bh;
[Ah, Bh, Ch, stats] = jCAB(D.X, D.dX, opts);

% save fit
clear output;
output.name = [methodName_A '_' methodName_B];
output.Ah = Ah;
output.Bh = Bh;
output.Ch = Ch;
output.stats = stats;

%% compare objective values

plotObjectiveValues(fits);
printSummaryStats(fits);
