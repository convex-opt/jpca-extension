function stats = summarizeFits(X, Xd, Ah, Bh, Ch, opts)

    % rsq for fitting estimated latent dynamics
    Zd = Xd*Ah;
    Zrot = X*Ah*Bh;
    varZd = sum(Zd(:).^2);  % original Xd data variance
    fitErr = Zd - Zrot;
    varErr = sum(fitErr(:).^2);    
    RsqDyn = (varZd - varErr)/varZd; % var explained by fit

    % pct. of variance explained by dim reduction
    varObs = sum(var(X));
    varCaptDimRed = sum(var(X*Ah))/varObs;
    varCaptDimRedRot = sum(var(X*Ah*Bh))/varObs;

    % add results to struct
    stats.rsq_dynamics = RsqDyn;
    stats.varExplained_dimred = varCaptDimRed;
    stats.varExplained_dimredrot = varCaptDimRedRot;
    stats.objValue_full = objFull(X,Xd,Ah,Bh,Ch,opts.lambda);
    stats.objValue_dimred = objDimRed(X,Ah,Ch);
    stats.objValue_latdyn = objLatDyn(X,Xd,Ah,Bh);

end
