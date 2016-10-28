function [D, Data] = loadNeuralData(infile, condNums)
    data = load(infile);
    if nargin < 2
        condNums = 1:numel(data.Data); % use all conditions by default
    end
    nConds = numel(condNums);

    if nConds == 1
        X = data.Data(condNums).A;
        Xd = diff(X);
        X = X(1:end-1,:);
    else % combine across conditions
        nt = size(data.Data(condNums(1)).A,1);
        X = vertcat(data.Data(condNums).A);
        bunchOtruth = true(nt-1,1);
        maskT1 = repmat([bunchOtruth;false], nConds, 1);
        maskT2 = repmat([false;bunchOtruth], nConds, 1);
        Xd = X(maskT2,:) - X(maskT1,:);
        X = X(maskT1,:);
    end

    D.X = X;
    D.Xd = Xd;
    
    % keep format that jPCA will use
    Data = data.Data(condNums); Data = rmfield(Data, 'times');

end
