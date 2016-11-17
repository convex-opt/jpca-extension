function v = objLatDyn(X, Y, A, B)
    v = sum(sum((Y*A - X*A*B).^2));
end
