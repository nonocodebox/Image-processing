function [pyr, filter] = laplacianPyramid(im, maxLevels, filterSize)
%LaplacianPyramid Builds a Laplacian pyramid, the size of the
% pyramid is not greater than maxLevels.

    narginchk(3, 3);
    nargoutchk(0, 2);

    try
        [gauss_pyr, filter] = gaussianPyramid(im, maxLevels, filterSize);
        pyr_size = size(gauss_pyr);
        pyr_size = pyr_size(1);

        pyr  = cell(pyr_size, 1);
        pyr{pyr_size} =  gauss_pyr{pyr_size};

        for i = (pyr_size - 1):-1:1
            level_size = size(gauss_pyr{i});
            expanded = expand(gauss_pyr{i+1}, filter);
            expanded = expanded(1:level_size(1), 1:level_size(2));
            
            L_i = (gauss_pyr{i} - expanded);
            pyr{i} = L_i;
        end

    catch err
        disp(strcat('ERROR: ', err.identifier));
        pyr = [];
        filter = [];
    end

end

