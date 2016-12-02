function v = gradA(X, Y, A, B, C, lambda)
% gradient w.r.t. A of |X - XAC'|_F^2 + ?|YA - XAB|_F^2
    v = gradObj1A(X,A,C) + lambda*gradObj2A(X,Y,A,B);
end

function v = gradObj1A(X, A, C)
% gradient w.r.t. A of |X - XAC'|_F^2
    v = 2*(X'*X*A*(C'*C) - X'*X*C);
end

function v = gradObj2A(X, Y, A, B)
% gradient w.r.t. A of |YA - XAB|_F^2
    v = 2*((Y'*Y)*A - X'*Y*A*B' - Y'*X*A*B + X'*X*A*(B*B'));
end
