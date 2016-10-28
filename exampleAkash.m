%% cd to the dir containing this script

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

%% generate latents and observations

n = 200; % # trials
k = 5; % latent dimensionality
p = 10; % observation dimensionality
rng(1334); % set rand seed

xNoise_levels = [0.1 1 10];
zNoise_level = .1;
for i_noise = 1
    D = simulateData(n, k, p, pi/3, zNoise_level, i_noise); % data struct

    % for saving output of various optimization methods
    output = struct('vs', [], 'angs', [], 'Ah', [], 'Bh', [], 'Ch', []);

    %% plot
    %plotLatentsAndObservations(D.Z, D.X);
    %plotLatentsAndObservations(D.Z_test, D.X_test);

    [u,d,v]=svd(D.X','econ');
    A_pca = u(:,1:k);
    A_model = D.A;
    pcaModel_angle = rad2deg(subspace(A_model,A_pca));

    %% solve
    lambda_vals = [0.1 1 10 100];
    for i_lambda = 1
        methodName = 'oblique'; % 'projGrad', 'stiefel', 'oblique', or 'simple'
        opts = struct('methodName', methodName, 'lambda', i_lambda, 'maxiters', 25, ...
            'nLatentDims', size(D.A,2));
        opts.A = D.A; opts.B = D.B; % for keeping track of objective values
        opts.X_test = D.X_test;
        opts.Xd_test = D.Xd_test;

        [Ah, Bh, Ch, info] = minABC(D.X, D.Xd, opts);

        % save vs, angs
        output.Ah.(methodName) = Ah;
        output.Bh.(methodName) = Bh;
        output.Ch.(methodName) = Ch;
        output.vs.(methodName) = info.vs;
        output.angs.(methodName) = info.angs;
        output.vs_test.(methodName) = info.vs_test;

        %% compare objective values
        plotObjectiveValues(output.vs, output.angs);
        plotObjectiveValues(output.vs_test, output.angs);
    end
end