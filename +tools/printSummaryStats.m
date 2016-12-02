function summary = printSummaryStats(output)
    ratf = @(a) a(1)/a(2);

    % this function can print out a comparison of fits.stats
    jp = output.stats(1);
    jc = output.stats(end);
    
    j1 = 100*[jp.rsq_dynamics jc.rsq_dynamics];
    j2 = 100*[jp.varExplained_dimred jc.varExplained_dimred];
    j3 = [jc.objValue_full jc.objValue_dimred jc.objValue_latdyn ...
        jc.objValue_sum];
    imp = [diff(j1) diff(j2)];
    rt = ratf(imp);
    
    disp('------------------------');
    disp(['lambda = ' num2str(output.opts.lambda)]);
    disp(['# iters = ' num2str(numel(output.stats))]);
    disp(['dynamics: ' num2str(j1)]);
    disp(['dimred: ' num2str(j2)]);
    disp(['improvement: ' num2str(imp)]);
    disp(['ratio: ' num2str(rt)]);    
    disp(['objValDimRed = ' num2str(j3(2))]);
    disp(['objValLatDyn = ' num2str(j3(3))]);
    disp(['objValWeighted = ' num2str(j3(1))]);
    disp(['objValSum = ' num2str(j3(4))]);    
    disp('------------------------');
    
    summary = [j1 j2 imp rt j3]';

end
