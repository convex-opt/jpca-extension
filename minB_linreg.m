function Bh = minB_linreg(X, Y, A)
% find Bh s.t. Bh = | YA - XAB |^2_F

    Bh = (X*A)\(Y*A); % B s.t. YA = (XA)B

end
