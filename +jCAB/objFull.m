function [v, g] = objFull(X, Y, A, B, C, lambda)
    v = jCAB.objDimRed(X,A,C) + lambda*jCAB.objLatDyn(X,Y,A,B);
    if nargout > 1
        % return gradient value also
        g = jCAB.gradA(X, Y, A, B, C, lambda);
    end
end
