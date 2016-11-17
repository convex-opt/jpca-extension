function Ar = nearestOrthonormal(A)
% find nearest orthonormal matrix to A
    [u,s,v] = svd(A'*A, 'econ');
    sinv = diag(1./sqrt(diag(s))); % inverse of sqrt of eigenvals
    A2 = u*sinv*v'; % (A'*A)^{-1/2}
    Ar = A*A2; % Ar is the closest orthornormal matrix to A, in |.|_F^2
end
