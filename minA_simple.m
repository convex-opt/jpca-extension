function Ah = minA_simple(X, Y, B, C)
% find (orthonormal?) Ah s.t. Ah = argmin | YA - XAB |^2_F

    objA = @(A) sum(sum((Y*A - X*A*B).^2));
    opts = optimoptions(@fminunc, 'Algorithm', 'quasi-newton', ...
        'Display', 'none');
    Ah = fminunc(objA, C, opts); % need gradient...
    [U,~,V] = svd(Ah, 'econ'); Ah = U*V'; % orthonormalize C
    
end
