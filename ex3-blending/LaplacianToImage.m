function [ img ] = LaplacianToImage(lpyr, filter, coeffMultVec)
%LaplacianToImage Builds the original image from a Laplacian pyramid giving a 
% coefficient vector.

try
    img = [];
    
    narginchk(3, 3);
    nargoutchk(0, 1);
    
    coeff_size = size(coeffMultVec);
    pyr_size = size(lpyr);
    
    if coeff_size(2) ~= pyr_size(1)
        disp('ERROR: invalid coefficients size.');
        return;
    end
    
    pyr_size = pyr_size(1);

    img = lpyr{pyr_size} * coeffMultVec(pyr_size);
    for i = (pyr_size -1):-1:1
        img =  Expand(img, filter) + lpyr{i} * coeffMultVec(i);
    end
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    img = [];
    return;
end

end

