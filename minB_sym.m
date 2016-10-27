function Bh = minB_sym(X, Y, A)
% find Bh s.t. Bh = | YA - XAB |^2_F

    % placeholder: want to enforce Bh has no rotational dynamics, i.e.,
    % Bh is symmetric
    Z = Y*A;
    m1 = fitlm(X*A, Z(:,1));
    m2 = fitlm(X*A, Z(:,2));
    Bh = [m1.Coefficients.Estimate(2:end) ...
        m2.Coefficients.Estimate(2:end)]; % ignore bias
    
end
