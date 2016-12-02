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

    %% training data
    nse = zNseMult*randn(n,k);
    Z = nan(n,k);
    Z(1,:) = randn(1,k); % random starting point
    for ii = 2:n
        Z(ii,:) = (B + eye(k))*Z(ii-1,:)' + nse(ii,:)';
    end
    Z = bsxfun(@plus, Z, -mean(Z)); % mean center

    % generate observations
    A0 = rand(p,k);
    [A,s,v] = svd(A0, 'econ'); % A is observation matrix
%     A = A0;
    obs_nse = xNseMult*randn(n,p);
    X = Z*A' + obs_nse;    

    % find X-dot, i.e., time derivative of X
    dX = diff(X);
    X = X(1:end-1,:);
    X = bsxfun(@plus, X, -mean(X)); % mean center

    %% test data
    nse = zNseMult*randn(n,k);
    Ztest = nan(n,k);
    Ztest(1,:) = randn(1,k); % random starting point
    for ii = 2:n
        Ztest(ii,:) = (B + eye(k))*Ztest(ii-1,:)' + nse(ii,:)';
    end
    Ztest = bsxfun(@plus, Ztest, -mean(Ztest)); % mean center

    % generate observations
    obs_nse = xNseMult*randn(n,p);
    Xtest = Ztest*A' + obs_nse;    

    % find Xtest-dot, i.e., time derivative of Xtest
    dXtest = diff(Xtest);
    Xtest = Xtest(1:end-1,:);
    Xtest = bsxfun(@plus, Xtest, -mean(Xtest)); % mean center
    
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
