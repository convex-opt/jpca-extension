function fcn = getMinBFcn(method)
    switch method
        case 'antisym' % i.e., in jPCA
            fcn = @minB_antisym;
        case 'sym'
            fcn = @minB_sym;
        otherwise
            fcn = @minB_linreg;
    end
end
