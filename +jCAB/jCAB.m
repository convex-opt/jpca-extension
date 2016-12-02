function [Ah, Bh, Ch, iters, stats] = jCAB(X, dX, opts)
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
        'verbosity', 0, ...
        'nLatentDims', 2, 'maxiters', 50, 'tol', 1e-6);
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
    As = {}; Bs = {}; Cs = {};
    As = [As Ah]; Bs = [Bs Bh]; Cs = [Cs Ch];
    deltas = [];
    for ii = 1:opts.maxiters
        if opts.verbosity > 0
            disp(['iter #' num2str(ii)]);
        end
        
        Ah0 = Ah; Bh0 = Bh; Ch0 = Ch;
        Bh = minB(X, dX, Ah); % linear regression, e.g.
        Ch = jCAB.minC(X, Ah); % low-rank procrustes
        Ah = minA(X, dX, Ah, Bh, Ch, opts.lambda); % gradient descent
        if opts.enforceOrthonormal_A && abs(norm(Ah) - 1) > 1e-3
            % n.b. orthonormalize Ah
            warning('ortho');
            Ah = tools.nearestOrthonormal(Ah);
        end        
        
        % keep track of objective values and variance explained
        if opts.keepStats
            curstats = tools.fitStats(X, dX, Ah, Bh, Ch, opts);
            if ii > 1 && curstats.objValue_full > stats(end).objValue_full+ (1e-3)
                warning(['not descending on iter #' num2str(ii)]);
            end
            stats = [stats curstats];
            if opts.verbosity > 1
                disp(curstats);
            end
        end
        As = [As Ah]; Bs = [Bs Bh]; Cs = [Cs Ch];
        [dA, dB, dC] = deltaIterate(As, Bs, Cs, ii);
        if opts.verbosity > 1
            disp(num2str([dA dB dC]));
        end
        deltas = [deltas; [dA dB dC]];
        if all([dA dB dC] < opts.tol)
            if opts.verbosity > 0
                disp(['Converged after ' num2str(ii) ' iterations']);
            end
            break;
        end
    end
    iters.Ah = As; iters.Bh = Bs; iters.Ch = Cs; iters.deltas = deltas;

end

function [dA, dB, dC] = deltaIterate(Ahs, Bhs, Chs, ii)
    dA = norm(Ahs{ii+1} - Ahs{ii}, 'fro');
    dB = norm(Bhs{ii+1} - Bhs{ii}, 'fro');
    dC = norm(Chs{ii+1} - Chs{ii}, 'fro');
end
