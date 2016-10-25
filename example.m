%% cd to the dir containing this script

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

%% generate latents and observations

n = 200; % # trials
k = 2; % latent dimensionality
p = 3; % observation dimensionality
rng(1334); % set rand seed
D = simulateData(n, k, p); % data struct

% for saving output of various optimization methods
output = struct('vs', [], 'angs', [], 'Ah', [], 'Bh', [], 'Ch', []);

%% plot

plotLatentsAndObservations(D.Z, D.X);

%% solve

methodName = 'simple'; % 'projGrad', 'stiefel', or 'simple'
opts = struct('methodName', methodName, 'lambda', 1.0, 'maxiters', 25, ...
    'nLatentDims', size(D.A,2));
opts.A = D.A; opts. B = D.B; % for keeping track of objective values

[Ah, Bh, Ch, info] = minABC(D.X, D.Xd, opts);

% save vs, angs
output.Ah.(methodName) = Ah;
output.Bh.(methodName) = Bh;
output.Ch.(methodName) = Ch;
output.vs.(methodName) = info.vs;
output.angs.(methodName) = info.angs;

%% compare objective values

plotObjectiveValues(output.vs, output.angs);
