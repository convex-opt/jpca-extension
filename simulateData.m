function D = simulateData(n, k, p, th, zNseMult, xNseMult)
    if nargin < 4
        th = pi/3;
    end
    if nargin < 5
        zNseMult = 0.1;
    end
    if nargin < 6
        xNseMult = 0.4;
    end

    % generate latent dynamics
    B = [cos(th) -sin(th); sin(th) cos(th)] - eye(k); % B is dynamics matrix

    % confirm that B has stable cycles (src: https://goo.gl/3ghNTx)
    assert(all([trace(B) < 0; det(B) > 0]));

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
    obs_nse = xNseMult*randn(n,p);
    X = Z*A' + obs_nse;    

    % find X-dot, i.e., time derivative of X
    Xd = diff(X);
    X = X(1:end-1,:);
    X = bsxfun(@plus, X, -mean(X)); % mean center

    % save data in struct for portability
    D.X = X;
    D.Xd = Xd; % X-dot
    D.Z = Z;
    D.A = A;
    D.B = B;
    D.n = n;
    D.k = p;
    D.p = p;
    D.th = th;
    D.zNseMult = zNseMult;
    D.xNseMult = xNseMult;
end
