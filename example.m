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

lambda = 1;

% objective: minimize reconstruction error of observations
%   and fit of dynamics for latents (Z = XA)
% curobj = @(X1,X2,Ah,Bh,Ch) objDimRed(X1,Ah,Ch) + lambda*objRotDyn(X1,X2,Ah,Bh);

[~,~,Ah] = svd(X, 'econ');
Ah = Ah(:,1:k); %  initialize with PCA solution

minA = getMinAFcn('simple'); % 'projGrad', 'stiefel', or 'simple'

maxiters = 50;
vs = nan(maxiters,3); % objective, and its terms
angs = nan(maxiters,2); % subspace angle between truth and estimate
for ii = 1:maxiters
    Bh = minB(X, Xd, Ah);
    Ch = minC(X, Ah);
    Ah = minA(X, Xd, Bh, Ch, lambda);
    vs(ii,:) = [objFull(X,Xd,Ah,Bh,Ch,lambda) objDimRed(X,Ah,Ch) objRotDyn(X,Xd,Ah,Bh)];
    angs(ii,:) = [rad2deg(subspace(B,Bh)) rad2deg(subspace(A, Ah))];
end

%% view objective values

nd = size(vs,2) + size(angs,2);
ncols = floor(sqrt(nd)); nrows = ceil(nd / ncols);

% total objective, reconstruction error, and fit of latent dynamics
vsNms = {'Full', 'DimRed', 'RotDyn'};
figure; set(gcf, 'color', 'w');
for ii = 1:size(vs,2)
    subplot(nrows, ncols, ii);
    plot(vs(:,ii));
    xlabel('iter #'); ylabel([vsNms{ii} ' objective value']); box off;
end

% angle between A and Ah, and B and Bh
angNms = {'?(B, Bh)', '?(A, Ah)'};
for ii = 1:size(angs,2)
    subplot(nrows, ncols, ii+size(vs,2));
    plot(angs(:,ii));    
    xlabel('iter #'); ylabel(angNms{ii});
    box off;
    ylim([0 90]);
    set(gca, 'YTick', 0:30:90);
    set(gca, 'YTickLabel', arrayfun(@num2str, 0:30:90, 'uni', 0));
end

