%% cd to the dir containing this script

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

%% generate latents and observations

n = 200; % # trials
k = 2; % latent dimensionality
p = 3; % observation dimensionality
rng(1334); % set rand seed
D = simulateData(n, k, p);
Z = D.Z;
X = D.X;
Xd = D.Xd;
A = D.A;
B = D.B;

% for saving output of various optimization methods
vals = struct('vs', [], 'angs', []);

%% plot

figure; set(gcf, 'color', 'w');
clrs = summer(n); % color code for time

% plot latents
subplot(1,2,1); hold on;
for ii = 2:size(Z,1)
    plot(Z(ii-1:ii,1), Z(ii-1:ii,2), '-', 'Color', clrs(ii,:));
end
title(['latents (' num2str(k) 'd)']);

% plot observations
subplot(1,2,2); hold on;
for ii = 2:size(X,1)
    plot3(X(ii-1:ii,1), X(ii-1:ii,2), X(ii-1:ii,3), '-', ...
        'Color', clrs(ii,:));
end
title(['observations (' num2str(p) 'd)']);

%% solve

methodMinA = 'projGrad'; % 'projGrad', 'stiefel', or 'simple'
lambda = 1.0; % higher values weight the dynamics more, relative to dim-red
maxiters = 25;

[~,~,Ah] = svd(X, 'econ');
Ah = Ah(:,1:k); %  initialize Ah with PCA solution
minA = getMinAFcn(methodMinA);

vs = nan(maxiters,3); % objective, and its terms
angs = nan(maxiters,2); % subspace angle between truth and estimate
for ii = 1:maxiters
    Bh = minB(X, Xd, Ah); % linear regression
    Ch = minC(X, Ah); % low-rank procrustes
    Ah = minA(X, Xd, Bh, Ch, lambda); % gradient descent
    if abs(norm(Ah) - 1) > 1e-3
        % n.b. orthonormalize Ah
        Ah = nearestOrthonormal(A);
    end
    
    % keep track of objective values, and angles between A and Ah, B and Bh
    vs(ii,:) = [objFull(X,Xd,Ah,Bh,Ch,lambda) objDimRed(X,Ah,Ch) ...
        objRotDyn(X,Xd,Ah,Bh)];
    angs(ii,:) = [rad2deg(subspace(B,Bh)) rad2deg(subspace(A, Ah))];
end

% save vs, angs
vals.vs.(methodMinA) = vs;
vals.angs.(methodMinA) = angs;

%% compare objective values

nd = size(vs,2) + size(angs,2);
ncols = floor(sqrt(nd)); nrows = ceil(nd / ncols);
fnms = fieldnames(vals.vs);

% total objective, reconstruction error, and fit of latent dynamics
vsNms = {'Full', 'DimRed', 'RotDyn'};
figure; set(gcf, 'color', 'w');
for ii = 1:size(vs,2)
    subplot(nrows, ncols, ii); hold on;
    for jj = 1:numel(fnms)
        cur_vs = vals.vs.(fnms{jj});
        plot(log(cur_vs(:,ii)));
    end
    xlabel('iter #');
    ylabel([vsNms{ii} ' objective value']);
    box off;
end

% angle between A and Ah, and B and Bh
angNms = {'?(B, Bh)', '?(A, Ah)'};
for ii = 1:size(angs,2)
    subplot(nrows, ncols, ii+size(vs,2)); hold on;
    for jj = 1:numel(fnms)
        cur_angs = vals.angs.(fnms{jj});
        plot(cur_angs(:,ii));
    end
    plot(angs(:,ii));    
    xlabel('iter #'); ylabel(angNms{ii});
    box off;
    ylim([0 90]);
    set(gca, 'YTick', 0:30:90);
    set(gca, 'YTickLabel', arrayfun(@num2str, 0:30:90, 'uni', 0));
end

