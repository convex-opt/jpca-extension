function v = objDimRed(X, A, C)
    v = norm(X - X*(A*C'), 'fro');
end
