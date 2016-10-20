function v = objRotDyn(X1, X2, A, B)
    v = norm(X2*A - X1*A*B, 'fro');
end
