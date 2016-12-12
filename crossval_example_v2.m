clear; clc; close all;

%% OPTION 1: load simulated data

% snrs = [nan 5 2 1 1/2 1/5 1/10];

zNses = [2 2 2];
% zNses = [0.5 2 5];
% xNses = [1 5 10];
xNses = [8 8 8];
% snrs = 0.7*ones(size(xNses));
snrs = [0.3 0.5 0.7 0.9];
snrs = [0.9];

all_outputs = cell(numel(snrs),1);
for kk = 1:numel(snrs)
    rng(1334); % set rand seed
    n = 200; % # trials
    k = 4; % latent dimensionality
    p = 10; % observation dimensionality
    rotOnly = true; % rotations only
    goal_snr = snrs(kk);
    zNse = zNses(kk);
    xNse = xNses(kk);
    D = tools.simulateData(n, k, p, zNse, xNse, goal_snr, rotOnly, pi/3); % data struct

    % solve

    outputs = [];

    methodName_A = 'stiefel'; % 'projGrad', 'stiefel', 'oblique', or 'simple'
    methodName_B = 'linreg'; % 'sym', 'antisym', or 'linreg'
    opts = struct('methodName_A', methodName_A, ...
        'methodName_B', methodName_B, ...
        'lambda', 1.0, 'maxiters', 100, ...
        'nLatentDims', k, ...
        'tol', 1e-4);

    % lmb_vals = [1e-10 0.001 0.003 0.01 0.03 0.1 0.3 1 3 10 30];
%     lmb_vals = [0.01 0.1 1 10 20 50];
    lmb_vals = [0.1 1];
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
        output.test_stats(1) = tools.fitStats(D.Xtest, D.dXtest, ...
            iters.Ah{1}, iters.Bh{1}, iters.Ch{1}, opts);
        output.test_stats(2) = tools.fitStats(D.Xtest, D.dXtest, ...
            Ah, Bh, Ch, opts);
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

    flds = {'objValue_dimred', 'objValue_latdyn'};
    dspNms = {'dimred', 'latdyn'};
    figure; set(gcf, 'color', 'w'); title(['snr: ' num2str(goal_snr)]);
    subplot(2,2,1); hold on;
    tools.plotjCABvsjPCA(outputs, flds, dspNms);
    subplot(2,2,2); hold on;
    tools.plotjCABvsjPCA(outputs, flds, dspNms, 'test_stats');
    flds = {'varExplained_dimred', 'rsq_dynamics'};
    dspNms = {'dimred', 'latdyn'};
    subplot(2,2,3); hold on;
    tools.plotjCABvsjPCA(outputs, flds, dspNms);
    ylim([0 100]);
    subplot(2,2,4); hold on;
    tools.plotjCABvsjPCA(outputs, flds, dspNms, 'test_stats');
    ylim([0 100]);

    tools.setPrintSize(gcf, 10, 6, 0);
    fignm = ['plots/snr_' num2str(goal_snr)];
%     export_fig(gcf, fignm, '-pdf');
    all_outputs{kk} = outputs;
end

%%

Ah = outputs(1).Ah;
tools.plotLatentsAndObservations(D.X*Ah, D.X);

Ah = outputs(end).Ah;
tools.plotLatentsAndObservations(D.X*Ah, D.X);

tools.plotLatentsAndObservations(D.X*D.A, D.X);
