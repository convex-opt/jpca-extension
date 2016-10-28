function Ah = minA_stiefel(X, Y, B, C, lambda, doOblique)
% find orthonormal Ah s.t. Ah = argmin |X - XAC'|_F^2 + ?|YA - XAB|_F^2
% using stiefel manifold optimization
    if nargin < 6
        doOblique = false;
    end

    Ah = C;
    [p,k] = size(Ah);

    % Create the problem structure.
    if doOblique
        manifold = obliquefactory(p,k);
    else
        manifold = stiefelfactory(p,k);
    end
    problem.M = manifold;

    % Define the problem cost function and its Euclidean gradient.
    problem.cost  = @(A) objFull(X, Y, A, B, C, lambda);
    problem.egrad = @(A) gradA(X, Y, A, B, C, lambda);

    % Numerically check gradient consistency (optional).
%     checkgradient(problem);

    % Solve.
    warning('off', 'manopt:getHessian:approx');
    [Ah, xcost, info, options] = trustregions(problem);

    % Display some statistics.
%     figure;
%     semilogy([info.iter], [info.gradnorm], '.-');
%     xlabel('Iteration number');
%     ylabel('Norm of the gradient of f');

end
