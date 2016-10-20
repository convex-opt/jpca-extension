%% generate latents and observations

n = 200; % # trials
k = 2; % latent dimensionality
p = 3; % observation dimensionality
rng(1334); % set rand seed

% generate latent dynamics

th = pi/3;
B = [cos(th) -sin(th); sin(th) cos(th)] - eye(k); % B is dynamics matrix

% confirm that B has stable cycles (src: https://goo.gl/3ghNTx)
assert(all([trace(B) < 0; det(B) > 0]));

nse = 0.1*randn(n,k);
Z = nan(n,k);
Z(1,:) = randn(1,k); % random starting point
for ii = 2:n
    Z(ii,:) = (B + eye(k))*Z(ii-1,:)' + nse(ii,:)';
end
Z = bsxfun(@plus, Z, -mean(Z)); % mean center

% generate observations
A0 = rand(p,k);
[A,s,v] = svd(A0, 'econ'); % A is observation matrix
obs_nse = 0.4*randn(n,p);
X = Z*A' + obs_nse;
X = bsxfun(@plus, X, -mean(X)); % mean center

%% plot

figure; set(gcf, 'color', 'w');
clrs = summer(n); % color code for time

% plot latents
subplot(1,2,1); hold on;
for ii = 2:n
    plot(Z(ii-1:ii,1), Z(ii-1:ii,2), '-', 'Color', clrs(ii,:));
end
title(['latents (' num2str(k) 'd)']);

% plot observations
subplot(1,2,2); hold on;
for ii = 2:n
    plot3(X(ii-1:ii,1), X(ii-1:ii,2), X(ii-1:ii,3), '-', ...
        'Color', clrs(ii,:));
end
title(['observations (' num2str(p) 'd)']);

%% solve

X1 = X(1:end-1,:);
X2 = diff(X);
lambda = 1;

% objective: minimize reconstruction error of observations
%   and fit of dynamics for latents (Z = XA)
curobj = @(X1,X2,Ah,Bh,Ch) objDimRed(X1,Ah,Ch) + lambda*objRotDyn(X1,X2,Ah,Bh);

[~,~,Ah] = svd(X1, 'econ');
Ah = Ah(:,1:k); %  initialize with PCA solution

minA = getMinAFcn('simple'); % 'projGrad', 'stiefel', or 'simple'

maxiters = 50;
vs = nan(maxiters,3); % objective, and its terms
angs = nan(maxiters,2); % subspace angle between truth and estimate
for ii = 1:maxiters
    Bh = minB(X1, X2, Ah);
    Ch = minC(X1, Ah);
    Ah = minA(X1, X2, Bh, Ch);
    vs(ii,:) = [curobj(X1,X2,Ah,Bh,Ch) objDimRed(X1,Ah,Ch) objRotDyn(X1,X2,Ah,Bh)];
    angs(ii,:) = [rad2deg(subspace(B,Bh)) rad2deg(subspace(A, Ah))];
end

%% view objective values

nd = size(vs,2) + size(angs,2);
ncols = floor(sqrt(nd)); nrows = ceil(nd / ncols);

% total objective, reconstruction error, and fit of latent dynamics
figure; set(gcf, 'color', 'w');
for ii = 1:size(vs,2)
    subplot(nrows, ncols, ii);
    plot(vs(:,ii));    
    xlabel('iter #'); ylabel('objective value'); box off;
end

% angle between A and Ah, and B and Bh
for ii = 1:size(angs,2)
    subplot(nrows, ncols, ii+size(vs,2));
    plot(angs(:,ii));    
    xlabel('iter #'); ylabel('angular error in subspace estimate');
    box off;
    ylim([0 90]);
    set(gca, 'YTick', 0:30:90);
    set(gca, 'YTickLabel', arrayfun(@num2str, 0:30:90, 'uni', 0));
end
