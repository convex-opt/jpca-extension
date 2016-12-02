function Ah = minA_projGrad(X, Y, A0, B, C, lambda)
% find orthonormal Ah s.t. Ah = |X - XAC'|_F^2 + ?|YA - XAB|_F^2
% using project gradient descent

    % placeholder: solve unconstrained problem, then find nearest
    % orthonormal version of that solution
    Ah = jCAB.minA_simple(X, Y, A0, B, C, lambda);
    Ah = tools.nearestOrthonormal(Ah);

end
