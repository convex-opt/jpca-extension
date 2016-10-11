function Ah = minA(X, C)
% find orthonormal Ah s.t. Ah = argmin | X - XCA |^2_F

    % Procrustes rotation (solution from 2006 Sparse PCA paper)
    [U,~,V] = svd((X'*X)*C, 'econ');
    Ah = U*V';

end
