function [v, g] = objFull(X, Y, A, B, C, lambda)
    v = objDimRed(X,A,C) + lambda*objRotDyn(X,Y,A,B);
    if nargout > 1
        % return gradient value also
        g = gradA(X, Y, A, B, C, lambda);
    end
end
