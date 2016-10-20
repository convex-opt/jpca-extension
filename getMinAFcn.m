function fcn = getMinAFcn(method)
    switch method
        case 'stiefel'
            fcn = @minA_stifel;
        case 'projGrad'
            fcn = @minA_projGrad;
        otherwise
            fcn = @minA_simple;
    end
end
