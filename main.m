%% cd to this dir, and set up paths

% tmp = matlab.desktop.editor.getActive;
% cd(fileparts(tmp.Filename));
setpaths; % add jPCA and manopt paths

%% OPTION 1: load simulated data

rng(1334); % set rand seed
n = 200; % # trials
k = 4; % latent dimensionality
p = 10; % observation dimensionality
rotOnly = true; % rotations only
D = tools.simulateData(n, k, p, 0.5, 10, rotOnly, pi/3); % data struct
% tools.plotLatentsAndObservations(D.Z, D.X);

%% OPTION 2: load neural data (use jPCA to preprocess)

data = load('data/exampleData.mat');
Data = data.Data; clear data;

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
clear D;
D.dX = X0(t2,:) - X0(t1,:);
D.X = X0(t1,:);

D.k = params.numPCs;

p = 100;
D.X = D.X(:,1:p);
D.dX = D.dX(:,1:p);

%% solve

outputs = [];

methodName_A = 'stiefel'; % 'projGrad', 'stiefel', 'oblique', or 'simple'
methodName_B = 'linreg'; % 'sym', 'antisym', or 'linreg'
opts = struct('methodName_A', methodName_A, ...
    'methodName_B', methodName_B, ...
    'lambda', 1.0, 'maxiters', 500, ...
    'nLatentDims', D.k, ...
    'verbosity', 0, ...
    'tol', 1e-3);

lms = [0.001 0.01 0.1 1 2 5];
% lms = 0;
for lm = lms
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
    output.summary = tools.printSummaryStats(output);
    
    outputs = [outputs; output];
end

%% compare objective values

tools.plotObjectiveValues(outputs);

sm = [outputs.summary];
lm = lms(1:size(sm,2));

plot.init;
subplot(1,2,1); hold on;
plot(lm, sm(1,:));
plot(lm, sm(2,:));
xlabel('\lambda');
ylabel('r^2 dynamics');

subplot(1,2,2); hold on;
plot(lm, sm(3,:));
plot(lm, sm(4,:));
xlabel('\lambda');
ylabel('r^2 dim red');
