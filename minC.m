function Ch = minC(X, Y, B, C0)
% find (orthonormal?) Ch s.t. Ch = argmin | YC - XCB |^2_F

    objC = @(C) sum(sum((Y*C - X*C*B).^2));
    opts = optimoptions(@fminunc, 'Algorithm', 'quasi-newton', ...
        'Display', 'none');
    Ch = fminunc(objC, C0, opts); % need gradient...
    [U,~,V] = svd(Ch, 'econ'); Ch = U*V'; % orthonormalize C
    
    % but this is dumb--need something better here, like orthogonalized CCA
    
    % to use FISTA: min_x g(x) + h(x)
    %    where g is smooth and convex, and h has known prox
    % so let g(x) = norm(X2*C - X1*C*B, 'fro') and h(x) = trace(C)
    % this will make C closer to low-rank
    %    (L1 instead of L0 norm for vectors is like trace instead of rank
    %    for matrices)
    
end

function v = proxTrace(Z, t)
    % prox for trace norm is from lecture notes on prox grad
    [U,S,V] = svd(Z, 'econ');
    St = diag(max(0, diag(S) - t)); % soft-threshold of eigenvals
    v = U*St*V';
end

function d = nablaG(x)
    % gradient of norm(X2*C - X1*C*B, 'fro') w.r.t. C
end
