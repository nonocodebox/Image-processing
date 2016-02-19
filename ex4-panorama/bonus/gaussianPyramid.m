function [pyr, filter] = gaussianPyramid(im, maxLevels, filterSize)
%gaussianPyramid Builds a Gaussian pyramid pyramid, the size of the
% pyramid is not greater than maxLevels.

    narginchk(3, 3);
    nargoutchk(0, 2);

    try
        pyr = [];
        filter = create1DGaussianFilter(filterSize);

        gauss_size = sum(size(filter));

        if gauss_size == 0
            return;
        end

        image_size = size(im);
        rows = image_size(1);
        cols = image_size(2);

        if cols <= 30 || rows <= 30
             disp('ERROR: invalid image size.');
             return;
        end

        c = min(floor(log2(rows/30)) + 1, floor(log2(cols/30)) + 1);
        levels = min(c , maxLevels);
        % Plus one is for the place of 30x30

        pyramid  = cell(levels, 1);
        pyramid{1} = im;

        for i = 2:levels
            G_i = reduce(pyramid{i-1}, filter);
            pyramid{i} = G_i;
        end

        pyr = pyramid;

    catch err
        disp(strcat('ERROR: ', err.identifier));
        filter = [];
        pyr =[];
    end

end

