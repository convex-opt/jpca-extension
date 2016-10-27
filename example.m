%% cd to the dir containing this script

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

%% generate latents and observations

n = 200; % # trials
k = 2; % latent dimensionality
p = 3; % observation dimensionality
rng(1334); % set rand seed
D = simulateData(n, k, p, pi/3, 0.5, 3.5); % data struct

% for saving output of various optimization methods
output = struct('vs', [], 'angs', [], 'Ah', [], 'Bh', [], 'Ch', []);

%% plot

plotLatentsAndObservations(D.Z, D.X);

%% solve

methodName_A = 'stiefel'; % 'projGrad', 'stiefel', or 'simple'
methodName_B = 'antisym'; % 'sym', 'antisym', or 'linreg'
opts = struct('methodName_A', methodName_A, ...
    'methodName_B', methodName_B, ...
    'lambda', 1.0, 'maxiters', 25, ...
    'nLatentDims', size(D.A,2));
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

Data(1).A = D.X;
params = struct('numPCs', k, ... % latent dimensionality (should be even)
    'normalize', false, ... % across time and conditions
    'softenNorm', 10, ... % ignored if not normalizing
    'meanSubtract', false, ... % only does across-condition mean
    'suppressBWrosettes', true, ... % don't plot
    'suppressHistograms', true, ... % don't plot
    'suppressText', false);
[Projection, Summary] = jPCA(Data, [], params);
