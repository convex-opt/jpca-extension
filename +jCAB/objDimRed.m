function v = objDimRed(X, A, C)
    v = sum(sum((X - X*A*C').^2));
end
