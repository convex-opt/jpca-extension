function D = simulateData(n, k, p, zNseMult, xNseMult, rotOnly, th)    
    if nargin < 4
        zNseMult = 0.1;
    end
    if nargin < 5
        xNseMult = 0.4;
    end
    if nargin < 6
        rotOnly = false;
    end
    if nargin < 7
        th = pi/3;
    end

    % generate latent dynamics
    if rotOnly && (k == 2 || k == 4)
        B = [cos(th) -sin(th); sin(th) cos(th)] - eye(2);
        if k == 4
            B = [B zeros(2); zeros(2) B];
        end
        % confirm that B has stable cycles (src: https://goo.gl/3ghNTx)
        assert(all([trace(B) < 0; det(B) > 0]), [trace(B) det(B)]);
    else
        assert(false); % don't know how to make these yet without exploding
    end

    %% training/testing data
    N = 2*n; % first n for training, last n for testing
    
    nse = zNseMult*randn(N,k);
    Z = nan(N,k);
    Z(1,:) = randn(1,k); % random starting point
    for ii = 2:N
        Z(ii,:) = (B + eye(k))*Z(ii-1,:)' + nse(ii,:)';
    end
    Z = bsxfun(@plus, Z, -mean(Z)); % mean center

    % generate observations
    % OPTION #1: noise everywhere
    [A,~,~] = svd(rand(p,k), 'econ'); % A is observation matrix
    obs_nse = xNseMult*randn(N,p);    
    X = Z*A' + obs_nse;
    % OPTION #2: noise orthogonal to random projection
%     goal_snr = 0.5;
%     [X,A,~] = tools.latentObsWithOrthNoise(Z, p, goal_snr);

    % find X-dot, i.e., time derivative of X
    dX = diff(X);
    X = X(1:end-1,:);
    X = bsxfun(@plus, X, -mean(X)); % mean center
    
    % split into train/test
    isTestInd = true(N-1,1); isTestInd(1:n) = false;
    Xtest = X(isTestInd,:);
    dXtest = dX(isTestInd,:);
    Ztest = Z(isTestInd,:);
    X = X(~isTestInd,:);
    dX = dX(~isTestInd,:);
    Z = Z(~isTestInd,:);
    
    %% save data in struct for portability
    D.X = X;
    D.dX = dX; % X-dot
    D.Z = Z;
    D.Xtest = Xtest;
    D.dXtest = dXtest;
    D.Ztest = Ztest;
    D.A = A;
    D.B = B;
    D.n = n;
    D.k = k;
    D.p = p;
    D.th = th;
    D.zNseMult = zNseMult;
    D.xNseMult = xNseMult;
end
