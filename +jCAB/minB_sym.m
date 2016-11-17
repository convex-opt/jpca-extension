function Bh = minB_sym(X, Y, A)
% find Bh s.t. Bh = | YA - XAB |^2_F

    % placeholder: want to enforce Bh has no rotational dynamics, i.e.,
    % Bh is symmetric
    Bh = (X*A)\(Y*A); % B s.t. (XA)B = YA
    
end
