function stats = fitStats(X, dX, Ah, Bh, Ch, opts)

    % rsq for fitting estimated latent dynamics
    dZ = dX*Ah;
    Zrot = X*Ah*Bh;
    varZd = sum(dZ(:).^2);  % original Xd data variance
    fitErr = dZ - Zrot;
    varErr = sum(fitErr(:).^2);    
    RsqDyn = (varZd - varErr)/varZd; % var explained by fit
%     RsqDyn = sum(var(Zrot))/sum(var(Zd)); % same as above

    % rsq for fitting high-d dynamics of observed data
    dXhat = X*(Ah*Bh*Ah');
    RsqDyn2 = sum(dXhat(:).^2)/sum(dX(:).^2);

    % pct. of variance explained by dim reduction
    varObs = sum(var(X));
    varCaptDimRed = sum(var(X*Ah))/varObs;
    varObsdX = sum(var(dX));
    varCaptDimRed_dX = sum(var(dX*Ah))/varObsdX;
    
%     fitErrorM_2D = fitErr*jPCs(:,1:2); % err projected into primary plane
%     dState_2D = dX*jPCS(:,1:2); % project dX into primary plane
%     varErr_2D = sum(fitErrorM_2D(:).^2);
%     vardX_2D = sum(dState_2D(:).^2); % and get its variance
%     % how much is explained by the overall fit via M
%     RsqDyn_2d = (vardX_2D - varErr_2D)/vardX_2D;

    % keep track of angles between A and Ah, B and Bh
    if isfield(opts, 'A') && isfield(opts, 'B')
        angs = [rad2deg(subspace(opts.B, Bh)) ...
            rad2deg(subspace(opts.A, Ah)) ...
            rad2deg(subspace(Ah, Ch))];
    else
        angs = [];
    end

    % add results to struct
    stats.rsq_dynamics = RsqDyn;
    stats.rsq_dynamics_raw = RsqDyn2;
    stats.varExplained_dimred = varCaptDimRed;
    stats.varExplained_dimred_dx = varCaptDimRed_dX;
    stats.objValue_full = jCAB.objFull(X,dX,Ah,Bh,Ch,opts.lambda);
    stats.objValue_dimred = jCAB.objDimRed(X,Ah,Ch);
    stats.objValue_latdyn = jCAB.objLatDyn(X,dX,Ah,Bh);
    stats.objValue_sum = stats.objValue_dimred + stats.objValue_latdyn;
    stats.angles = angs;

end
