function setPrintSize(fig, wd, ht, mrg)
    if nargin < 4
        mrg = 0.125;
    end
    set(fig, 'PaperUnits', 'inches');
    set(fig, 'Position', [0 0 wd*100 ht*100]);
    set(fig, 'PaperSize', [wd+2*mrg ht+2*mrg]);
    set(fig, 'PaperPosition', [mrg mrg wd ht]);
end
