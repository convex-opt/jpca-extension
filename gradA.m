function v = gradA(X, Y, A, B, C, lambda)
% gradient w.r.t. A of |YA - XAB|_F^2 + ?|X - XAC'|_F^2

    v = gradObj1A(X,Y,A,B,C) + lambda*gradObj2A(X,Y,A,B,C);
end

function v = gradObj1A(X, Y, A, B, C)
% gradient w.r.t. A of |YA - XAB|_F^2

end

function v = gradObj2A(X, Y, A, B, C)
% gradient w.r.t. A of |X - XAC'|_F^2

end
