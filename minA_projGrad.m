function Ah = minA_projGrad(X, Y, B, C, lambda)
% find orthonormal Ah s.t. Ah = |X - XAC'|_F^2 + ?|YA - XAB|_F^2
% using project gradient descent

    % placeholder: solve unconstrained problem, then find nearest
    % orthonormal version of that solution
    Ah = minA_simple(X, Y, B, C, lambda);
    Ah = nearestOrthonormal(Ah);

end
