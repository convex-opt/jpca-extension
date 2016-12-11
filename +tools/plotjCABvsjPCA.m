function plotjCABvsjPCA(outputs, valFlds, dspNms, statsFldNm)
    if nargin < 2
        valFlds = {'varExplained_dimred', 'rsq_dynamics'};
    end
    if nargin < 3
        dspNms = valFlds;
    end
    if nargin < 4
        statsFldNm = 'stats';
    end
        
    hold on;
    set(gca, 'FontSize', 16);
    sz = 25;
    
    xs = cellfun(@(d) d.lambda, {outputs.opts});
    [~,ix] = sort(xs);
    xs = xs(ix);
    outputs = outputs(ix);

%     xs = lmb_vals;

    sts = outputs(1).(statsFldNm);
    vs1 = cell(numel(valFlds),1);
    for jj = 1:numel(valFlds)
        vs1{jj} = 100*sts(1).(valFlds{jj});
    end
    
    vs2 = cell(numel(valFlds),1);
    for jj = 1:numel(valFlds)
        vs2{jj} = 100*getVals(outputs, statsFldNm, valFlds{jj}, true);
    end

    legNms = cell(2*numel(valFlds),1);
    for jj = 1:numel(valFlds)
        f = plot(xs, vs1{jj}*ones(size(xs)), '-');
        plot(xs, vs2{jj}, '.', 'Color', f.Color, 'MarkerSize', sz);
        legNms{2*jj-1} = [dspNms{jj} ' (jPCA)'];
        legNms{2*jj} = [dspNms{jj} ' (jCAB)'];
    end

    xlabel('\lambda');
%     ylabel('% variance explained');
    set(gca, 'XScale', 'log');
    xlim([min(xs) max(xs)]);
%     ylim([0 100]);
    legend(legNms, 'Location', 'BestOutside');
%     legend({'dim red (jPCA)', 'dim red (jCAB)', ...
%         'dynamics (jPCA)',  'dynamics (jCAB)'}, ...
%         'Location', 'BestOutside');

end

function vs = getVals(outputs, statsFldNm, valFldNm, doLast)
    vs = nan(numel(outputs),1);
    for ii = 1:numel(outputs)
        sts = outputs(ii).(statsFldNm);
        if doLast
            vs(ii) = sts(end).(valFldNm);
        else
            vs(ii) = sts(1).(valFldNm);
        end
    end
end
