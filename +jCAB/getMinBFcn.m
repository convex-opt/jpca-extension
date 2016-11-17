function fcn = getMinBFcn(method)
    switch method
        case 'antisym' % i.e., in jPCA
            fcn = @jCAB.minB_antisym;
        case 'sym'
            fcn = @jCAB.minB_sym;
        otherwise
            fcn = @jCAB.minB_linreg;
    end
end
