function [D, Data] = loadNeuralData(infile, condNums)
    data = load(infile);
    if nargin < 2
        condNums = 1:numel(data.Data); % use all conditions by default
    end
    nConds = numel(condNums);

    X = vertcat(data.Data(condNums).A);
    X = bsxfun(@minus, X, mean(X));

    nt = size(data.Data(condNums(1)).A,1);
    bunchOtruth = true(nt-1,1);
    maskT1 = repmat([bunchOtruth;false], nConds, 1);
    maskT2 = repmat([false;bunchOtruth], nConds, 1);
    Xd = X(maskT2,:) - X(maskT1,:);
    X = X(maskT1,:);
%     X = bsxfun(@minus, X, mean(X));
    D.X = X;
    D.Xd = Xd;
    
    % keep format that jPCA will use
    Data = data.Data(condNums); Data = rmfield(Data, 'times');

end
