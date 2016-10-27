function Bh = minB_antisym(X, Y, A)
% find Bh s.t. Bh = | YA - XAB |^2_F

    % placeholder: want to enforce Bh has rotational dynamics only, i.e.,
    % Bh is antisymmetric
    Bh = (X*A)\(Y*A); % B s.t. (XA)B = YA
    
end
