function Bh = minB_linreg(X, Y, A)
% find Bh s.t. Bh = | YA - XAB |^2_F

    Bh = (X*A)\(Y*A); % B s.t. (XA)B = YA
%     Z = Y*A;
%     m1 = fitlm(X*A, Z(:,1));
%     m2 = fitlm(X*A, Z(:,2));
%     Bh = [m1.Coefficients.Estimate(2:end) ...
%         m2.Coefficients.Estimate(2:end)]; % ignore bias
    
end
