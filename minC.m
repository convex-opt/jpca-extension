function Ch = minC(X, A)
% find orthonormal Ch s.t. Ch = argmin | X - XAC^T |^2_F

    % Procrustes rotation (solution from 2006 Sparse PCA paper)
    [U,~,V] = svd((X'*X)*A, 'econ');
    Ch = U*V';

end
