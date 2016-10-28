function [Ah, Bh, Ch, info] = jCAB(X, Xd, opts)
    if nargin < 3
        opts = struct('lambda', 1, 'methodName_A', 'simple', ...
            'methodName_B', 'linreg', ...
            'nLatentDims', 2, 'maxiters', 50);
    end

    % preprocess
    X = bsxfun(@plus, X, -mean(X)); % X should be zero mean

    % choose iterative method for minimizing B, given A
    minB = getMinBFcn(opts.methodName_B);

    % n.b. if maxiters==0, and methodName_B == 'antisym', 
    %     then we should be solving A and B as in jPCA
    [~,~,Ah] = svd(X, 'econ');
    Ah = Ah(:,1:opts.nLatentDims); %  initialize Ah with PCA solution
    Bh = minB(X, Xd, Ah); % linear regression, e.g.

    % choose iterative method for minimizing A, given B and C
    minA = getMinAFcn(opts.methodName_A);

    vs = nan(opts.maxiters,3); % objective, and its terms
    angs = nan(opts.maxiters,3); % subspace angle between truth and estimate
    for ii = 1:opts.maxiters
        
        Ch = minC(X, Ah); % low-rank procrustes
        Ah = minA(X, Xd, Bh, Ch, opts.lambda); % gradient descent
        if abs(norm(Ah) - 1) > 1e-3
            % n.b. orthonormalize Ah
            Ah = nearestOrthonormal(Ah);
        end
        Bh = minB(X, Xd, Ah); % linear regression, e.g.

        % keep track of objective values
        vs(ii,:) = [objFull(X,Xd,Ah,Bh,Ch,opts.lambda) ...
            objDimRed(X,Ah,Ch) objLatDyn(X,Xd,Ah,Bh)];

        % keep track of angles between A and Ah, B and Bh
        if isfield(opts, 'A') && isfield(opts, 'B')
            angs(ii,:) = [rad2deg(subspace(opts.B, Bh)) ...
                rad2deg(subspace(opts.A, Ah)) ...
                rad2deg(subspace(Ah, Ch))];
        end
    end
    info.vs = vs;
    info.angs = angs;

end
