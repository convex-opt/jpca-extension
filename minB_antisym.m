function Bh = minB_antisym(X, Y, A)
% find Bh s.t. Bh = | YA - XAB |^2_F

    % want to enforce Bh has rotational dynamics only,
    %    i.e., Bh is antisymmetric
    % use jPCA's skewSymRegress:
    Bh = skewSymRegress(Y*A, X*A);
    
end
