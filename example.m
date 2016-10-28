%% cd to the dir containing this script

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

%% load data: simulate

n = 200; % # trials
k = 4; % latent dimensionality
p = 10; % observation dimensionality
rng(1334); % set rand seed
rotOnly = true; % rotations only
D = simulateData(n, k, p, 0.5, 3.5, rotOnly, pi/3); % data struct

plotLatentsAndObservations(D.Z, D.X);

%% load data: neural data from jPCA paper

[D, jD] = loadNeuralData('../jPCA_ForDistribution/exampleData.mat', 1:5);

%% init: prepare to save outputs of various optimization methods

fits = [];

%% solve

methodName_A = 'simple'; % 'projGrad', 'stiefel', or 'simple'
methodName_B = 'antisym'; % 'sym', 'antisym', or 'linreg'
opts = struct('methodName_A', methodName_A, ...
    'methodName_B', methodName_B, ...
    'lambda', 1.0, 'maxiters', 25, ...
    'nLatentDims', 4);
if isfield(D, 'A') && isfield(D, 'B')
    assert(opts.nLatentDims == size(D.A,2));
    assert(opts.nLatentDims == size(D.B,1));
    opts.A = D.A; opts.B = D.B; % for keeping track of objective values
end

[Ah, Bh, Ch, info] = jCAB(D.X, D.Xd, opts);

% save fit
clear output;
output.name = [methodName_A '_' methodName_B];
output.Ah = Ah;
output.Bh = Bh;
output.Ch = Ch;
output.objValues = info.vs;
output.angles = info.angs;
output.stats = summarizeFits(D.X, D.Xd, ...
    output.Ah, output.Bh, output.Ch, opts);
fits = [fits output];

%% run jPCA

params = struct('numPCs', opts.nLatentDims, ... % latent dimensionality
    'normalize', false, ... % across time and conditions
    'softenNorm', 10, ... % ignored if not normalizing
    'meanSubtract', false, ... % only does across-condition mean
    'suppressBWrosettes', true, ... % don't plot
    'suppressHistograms', true, ... % don't plot
    'suppressText', false);
[Projection, Summary] = jPCA(jD, [], params);

% save fit
clear output;
output.name = 'jPCA';
output.Ah = Summary.PCs;
output.Bh = Summary.Mskew;
output.Ch = output.Ah;
output.objValues = [];
output.angles = [];
output.stats = summarizeFits(D.X, D.Xd, ...
    output.Ah, output.Bh, output.Ch, opts);
% fits = [fits output];

%% compare objective values

plotObjectiveValues(fits);
printSummaryStats(fits);
