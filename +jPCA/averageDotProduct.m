function avgDP = averageDotProduct(angles, compAngle, varargin)
%% for computing the average dot product with a comparison angle    
    x = cos(angles-compAngle);
    
    if ~isempty(varargin)
        avgDP = mean(x.*varargin{1}) / mean(varargin{1});  % weighted sum
    else
        avgDP = mean(x);
    end
end
