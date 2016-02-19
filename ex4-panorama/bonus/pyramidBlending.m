function [ imBlend ] = pyramidBlending(im1, im2, mask, maxLevels, filterSizeIm, filterSizeMask)
%pyramidBlending Blends two greyscale images

    narginchk(6, 6);
    nargoutchk(0, 1);

    try
        imBlend = [];

        if ~isequal(size(im1), size(im2))
            disp('ERROR: invalid image sizes.');
            return;
        end

        if ~isequal(size(im1), size(mask))
            disp('ERROR: invalid mask size.');
            return;
        end

        [Gm, ~] = gaussianPyramid(double(mask), maxLevels, filterSizeMask);
        [L1, filter] = laplacianPyramid(double(im1), maxLevels, filterSizeIm);
        [L2, ~] = laplacianPyramid(double(im2), maxLevels, filterSizeIm);

        pyr_size = size(Gm);
        pyr_size = pyr_size(1);
        pyr = cell(pyr_size, 1);

        for i = 1:pyr_size
            L_i = Gm{i} .* L1{i} + (1 - Gm{i}) .* L2{i};
            pyr{i} = L_i;
        end

        imBlend = laplacianToImage(pyr, filter, ones(1, pyr_size));

    catch err
        disp(strcat('ERROR: ', err.identifier));
        imBlend = [];
    end

end
