function jPCs = getjPCsFromMskew(Mskew, Ared, numAnalyzedTimes)

    % get the eigenvalues and eigenvectors
    numPCs = size(Mskew,1);
    [V,D] = eig(Mskew); % V are the eigenvectors, D contains the eigenvalues
    evals = diag(D); % eigenvalues

    % the eigenvalues are usually in order, but not always.  We want the biggest
    [~,sortIndices] = sort(abs(evals),1,'descend');
    evals = evals(sortIndices);  % reorder the eigenvalues
    evals = imag(evals);  % get rid of any tiny real part
    V = V(:,sortIndices);  % reorder the eigenvectors (base on eigenvalue size)

    jPCs = zeros(size(V));
    for pair = 1:numPCs/2
        vi1 = 1+2*(pair-1);
        vi2 = 2*pair;

        VconjPair = V(:,[vi1,vi2]);  % a conjugate pair of eigenvectors
        evConjPair = evals([vi1,vi2]); % and their eigenvalues
        VconjPair = jPCA.getRealVs(VconjPair,evConjPair, Ared, numAnalyzedTimes);

        jPCs(:,[vi1,vi2]) = VconjPair;
    end

end
