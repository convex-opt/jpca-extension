function [Y,S,E] = latentObsWithOrthNoise(Z, p, goal_snr)
% given latents Z, maps Z to p-d using random projection (S)
%   after adding noise in directions orthogonal to the projection (E)
% 
% n.b. goal_snr is a unitless ratio of signal-to-noise variance
%   written in decibals: dB = 10*log10(goal_snr)
% 

    % find random k-d signal plane, and orthogonal noise plane
    [~,k] = size(Z);
    [U,~,~] = svd(rand(p,k));
    S = U(:,1:k); % signal plane
    E = U(:,k+1:end); % noise plane

    % map latents to high-d signal plane
    X = Z*S';

    % add observation noise only in orthogonal noise plane
    Z_nse = randn(size(X,1), size(E,2));
    nse = Z_nse*E'; % gaussian noise in noise plane
    sigma = sum(Z(:).^2)/(sum(nse(:).^2)*goal_snr); % noise strength
    Y = X + sqrt(sigma)*nse; % observation

    % figure; set(gca, 'FontSize', 12); hold on;
    % plot3(X(:,1), X(:,2), X(:,3), 'r.');
    % plot3(Y(:,1), Y(:,2), Y(:,3), 'k.');

end
