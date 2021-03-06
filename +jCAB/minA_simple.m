function Ah = minA_simple(X, Y, A0, B, C, lambda)
% find (orthonormal?) Ah s.t. Ah = |X - XAC'|_F^2 + l|YA - XAB|_F^2

    obj = @(A) jCAB.objFull(X, Y, A, B, C, lambda);
    opts = optimoptions(@fminunc, 'Algorithm', 'quasi-newton', ...
        'GradObj', 'on', 'Display', 'none');
    Ah = fminunc(obj, A0, opts); % need gradient...
%     [U,~,V] = svd(Ah, 'econ'); Ah = U*V'; % orthonormalize Ah
    
end
