function [Ah, Bh, Ch, info] = minABC(X, Xd, opts)
    if nargin < 3
        opts = struct('lambda', 1, 'methodName', 'simple', ...
            'nLatentDims', 2, 'maxiters', 50);
    end

    [~,~,Ah] = svd(X, 'econ');
    Ah = Ah(:,1:opts.nLatentDims); %  initialize Ah with PCA solution
    minA = getMinAFcn(opts.methodName);

    vs = nan(opts.maxiters,3); % objective, and its terms
    angs = nan(opts.maxiters,2); % subspace angle between truth and estimate
    for ii = 1:opts.maxiters
        Bh = minB(X, Xd, Ah); % linear regression
        Ch = minC(X, Ah); % low-rank procrustes
        Ah = minA(X, Xd, Bh, Ch, opts.lambda); % gradient descent
        if abs(norm(Ah) - 1) > 1e-3
            % n.b. orthonormalize Ah
            Ah = nearestOrthonormal(Ah);
        end

        % keep track of objective values
        if isfield(opts, 'A')
            vs(ii,:) = [objFull(X,Xd,Ah,Bh,Ch,opts.lambda) ...
                objDimRed(X,Ah,Ch) objRotDyn(X,Xd,Ah,Bh)];
        end
        % keep track of angles between A and Ah, B and Bh
        if isfield(opts, 'B')
            angs(ii,:) = [rad2deg(subspace(opts.B,Bh)) ...
                rad2deg(subspace(opts.A, Ah))];
        end
    end
    info.vs = vs;
    info.angs = angs;

end
