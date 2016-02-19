function [pyr, filter] = LaplacianPyramid(im, maxLevels, filterSize)
%LaplacianPyramid Builds a Laplacian pyramid, the size of the
% pyramid is not greater than maxLevels.

try
    narginchk(3, 3);
    nargoutchk(0, 2);
    
    [gauss_pyr, filter] = GaussianPyramid(im, maxLevels, filterSize);
    pyr_size = size(gauss_pyr);
    pyr_size = pyr_size(1);

    pyr  = cell(pyr_size, 1);
    pyr{pyr_size} =  gauss_pyr{pyr_size};

    for i = (pyr_size - 1):-1:1
        L_i = (gauss_pyr{i} - Expand(gauss_pyr{i+1}, filter));
        pyr{i} = L_i;
    end
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    pyr = [];
    filter = [];
    return;
end

end

