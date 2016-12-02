function fcn = getMinAFcn(method)
    switch method
        case 'stiefel'
            fcn = @jCAB.minA_stiefel;
        case 'oblique'
            fcn = @(X,Y,A0,B,C,lambda) jCAB.minA_stiefel(X,Y,A0,B,C,lambda,true);
        case 'projGrad'
            fcn = @jCAB.minA_projGrad;
        otherwise
            fcn = @jCAB.minA_simple;
    end
end
