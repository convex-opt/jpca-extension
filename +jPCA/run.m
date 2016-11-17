
jPCA_params.softenNorm = 5;
jPCA_params.suppressBWrosettes = true;
jPCA_params.suppressHistograms = true;
jPCA_params.numPCs = 6;
[Projection, Summary] = jPCA.jPCA(Data, [], jPCA_params);
