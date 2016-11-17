function [Ah, Bh, Ch, stats] = jCAB(X, dX, opts)
    % n.b. if maxiters==0, and methodName_B == 'antisym', 
    %     then we will be solving A and B as in jPCA
    if nargin < 3
        opts = struct();
    end
    defopts = struct('lambda', 1, 'methodName_A', 'simple', ...
        'methodName_B', 'linreg', ...
        'enforceOrthonormal_A', true, ...
        'keepStats', true, ...
        'Ah', [], 'Bh', [], ...
        'nLatentDims', 2, 'maxiters', 50);
    % set field to default value if field is not set
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    % preprocess
    X = bsxfun(@plus, X, -mean(X)); % X should be zero mean

    % choose iterative method for minimizing B, given A
    minB = jCAB.getMinBFcn(opts.methodName_B);

    % init Ah, Bh, Ch
    if ~isempty(opts.Ah)
        Ah = opts.Ah;
        assert(size(Ah,2) == opts.nLatentDims);
    else
        [~,~,Ah] = svd(X, 'econ');
        Ah = Ah(:,1:opts.nLatentDims); %  initialize Ah with PCA solution
    end
    if ~isempty(opts.Bh)
        Bh = opts.Bh;
        assert(size(Bh,1) == opts.nLatentDims);
        assert(size(Bh,2) == opts.nLatentDims);
    else
        Bh = minB(X, dX, Ah); % linear regression, e.g.
    end
    Ch = Ah;

    % choose iterative method for minimizing A, given B and C
    minA = jCAB.getMinAFcn(opts.methodName_A);

    stats = [];
    if opts.keepStats
        stats = [stats tools.fitStats(X, dX, Ah, Bh, Ch, opts)];
    end
    
    for ii = 1:opts.maxiters
        
        Ch = jCAB.minC(X, Ah); % low-rank procrustes
        Ah = minA(X, dX, Bh, Ch, opts.lambda); % gradient descent
        if opts.enforceOrthonormal_A && abs(norm(Ah) - 1) > 1e-3
            % n.b. orthonormalize Ah
            Ah = tools.nearestOrthonormal(Ah);
        end
        Bh = minB(X, dX, Ah); % linear regression, e.g.
        
        % keep track of objective values and variance explained
        if opts.keepStats
            stats = [stats tools.fitStats(X, dX, Ah, Bh, Ch, opts)];
        end
    end

end
