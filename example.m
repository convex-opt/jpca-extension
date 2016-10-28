%% cd to the dir containing this script

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

%% load data: simulate

n = 200; % # trials
k = 4; % latent dimensionality
p = 10; % observation dimensionality
rng(1334); % set rand seed
D = simulateData(n, k, p, pi/3, 0.5, 3.5); % data struct

plotLatentsAndObservations(D.Z, D.X);

%% load data: neural data from jPCA paper

[D, jD] = loadNeuralData('../jPCA_ForDistribution/exampleData.mat', 1:5);

%% init: prepare to save outputs of various optimization methods
output = struct('vs', [], 'angs', [], 'Ah', [], 'Bh', [], 'Ch', []);

%% solve

methodName_A = 'stiefel'; % 'projGrad', 'stiefel', or 'simple'
methodName_B = 'antisym'; % 'sym', 'antisym', or 'linreg'
opts = struct('methodName_A', methodName_A, ...
    'methodName_B', methodName_B, ...
    'lambda', 1.0, 'maxiters', 25, ...
    'nLatentDims', 4);
opts.A = D.A; opts.B = D.B; % for keeping track of objective values

[Ah, Bh, Ch, info] = jCAB(D.X, D.Xd, opts);

% save vs, angs
methodName = [methodName_A '_' methodName_B];
output.Ah.(methodName) = Ah;
output.Bh.(methodName) = Bh;
output.Ch.(methodName) = Ch;
output.vs.(methodName) = info.vs;
output.angs.(methodName) = info.angs;

%% compare objective values

plotObjectiveValues(output.vs, output.angs);

%% run jPCA

params = struct('numPCs', opts.nLatentDims, ... % latent dimensionality
    'normalize', false, ... % across time and conditions
    'softenNorm', 10, ... % ignored if not normalizing
    'meanSubtract', true, ... % only does across-condition mean
    'suppressBWrosettes', true, ... % don't plot
    'suppressHistograms', true, ... % don't plot
    'suppressText', false);
[Projection, Summary] = jPCA(jD, [], params);
