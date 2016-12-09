clear; clc; close all;

%% OPTION 1: load simulated data

rng(1334); % set rand seed
n = 200; % # trials
k = 4; % latent dimensionality
p = 10; % observation dimensionality
rotOnly = true; % rotations only
D = tools.simulateData(n, k, p, 0.5, 3.5, 0.5, rotOnly, pi/3); % data struct


%% solve

outputs = [];

methodName_A = 'stiefel'; % 'projGrad', 'stiefel', 'oblique', or 'simple'
methodName_B = 'linreg'; % 'sym', 'antisym', or 'linreg'
opts = struct('methodName_A', methodName_A, ...
    'methodName_B', methodName_B, ...
    'lambda', 1.0, 'maxiters', 100, ...
    'nLatentDims', k, ...
    'tol', 1e-4);

lmb_vals = [1e-10 0.001 0.003 0.01 0.03 0.1 0.3 1 3 10 30];
for i_lmb = 1:length(lmb_vals)
    lmb = lmb_vals(i_lmb);
    opts.lambda = lmb;
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
    
    % training objective value (weighted)
    trainObj_weighted(i_lmb) = jCAB.objFull(D.X,D.dX,Ah,Bh,Ch,lmb);
    
    % training objective value (unweighted)
    trainObj_unweighted(i_lmb) = jCAB.objFull(D.X,D.dX,Ah,Bh,Ch,1);
    
    % test objective value (weighted)
    testObj_weighted(i_lmb) = jCAB.objFull(D.Xtest,D.dXtest,Ah,Bh,Ch,lmb);
    
    % test objective value (unweighted)
    testObj_unweighted(i_lmb) = jCAB.objFull(D.Xtest,D.dXtest,Ah,Bh,Ch,1);
    
    % test objective value (unweighted, normalized to account for size of frobenius norm)
    testObj_unweighted_norm(i_lmb) = jCAB.objFull(D.Xtest,D.dXtest,Ah,Bh,Ch,1*p/k);
    
end

%% compare objective values

[~,idx]=min(testObj_unweighted);
norm_lmb = lmb_vals(idx)
[~,idx] = min(testObj_unweighted_norm);
unnorm_lmb = lmb_vals(idx)

figure; hold on;
semilogy(lmb_vals,trainObj_weighted)
semilogy(lmb_vals,testObj_weighted)
legend('train','test')
title('weighted')
xlabel('lambda'), ylabel('X + \lambda W')

figure; hold on;
semilogy(lmb_vals,trainObj_unweighted)
semilogy(lmb_vals,testObj_unweighted)
legend('train','test')
title('unweighted')
xlabel('lambda'), ylabel('X + W')

figure; hold on;
semilogy(lmb_vals,testObj_unweighted)
semilogy(lmb_vals,testObj_unweighted_norm)
legend('un-normalized','normalized')
title('unweighted')
xlabel('lambda'), ylabel('X + W')

