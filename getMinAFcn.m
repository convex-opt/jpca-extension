function fcn = getMinAFcn(method)
    switch method
        case 'stiefel'
            fcn = @minA_stiefel;
        case 'oblique'
            fcn = @(X,Y,B,C,lambda) minA_stiefel(X,Y,B,C,lambda,true);
        case 'projGrad'
            fcn = @minA_projGrad;
        otherwise
            fcn = @minA_simple;
    end
end
