function [ blendRGBImg ] = blendRGBImages(im1, im2, mask, maxLevels, filterSizeIm, filterSizeMask)
%BlendRGBImages Blends two RGB images.

    narginchk(6, 6);
    nargoutchk(0, 1);

    try
        blendRGBImg = zeros(size(im1));
        for j = 1:3
            blendRGBImg(:,:,j) = pyramidBlending(im1(:,:,j), im2(:,:,j), mask, maxLevels, filterSizeIm, filterSizeMask);
        end

    catch err
        disp(strcat('ERROR: ', err.identifier));
        blendRGBImg = [];
    end

end


