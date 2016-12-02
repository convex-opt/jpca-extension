function Ah = minA_stiefel(X, Y, A0, B, C, lambda, doOblique)
% find orthonormal Ah s.t. Ah = argmin |X - XAC'|_F^2 + ?|YA - XAB|_F^2
% using stiefel manifold optimization
    if nargin < 7
        doOblique = false;
    end
    [p,k] = size(A0); % initial guess

    % Create the problem structure.
    if doOblique
        manifold = obliquefactory(p,k);
    else
        manifold = stiefelfactory(p,k);
    end
    problem.M = manifold;

    % Define the problem cost function and its Euclidean gradient.
    problem.cost  = @(A) jCAB.objFull(X, Y, A, B, C, lambda);
    problem.egrad = @(A) jCAB.gradA(X, Y, A, B, C, lambda);

    % Numerically check gradient consistency (optional).
%     checkgradient(problem);

    % Solve.
    warning('off', 'manopt:getHessian:approx');
    options = struct('verbosity', 0); % totally silent
    [Ah, xcost, info, options] = trustregions(problem, A0, options);

    % Display some statistics.
%     figure;
%     semilogy([info.iter], [info.gradnorm], '.-');
%     xlabel('Iteration number');
%     ylabel('Norm of the gradient of f');

end
