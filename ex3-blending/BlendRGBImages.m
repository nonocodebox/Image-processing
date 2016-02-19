function [ blendRGBImg ] = BlendRGBImages(im1, im2, mask, maxLevels, filterSizeIm, filterSizeMask)
%BlendRGBImages Blends two RGB images.

try
    blendRGBImg = zeros(size(im1));
    for j = 1:3
        blendRGBImg(:,:,j) = pyramidBlending(im1(:,:,j), im2(:,:,j), mask(:,:,j), maxLevels, filterSizeIm, filterSizeMask);
    end
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    blendRGBImg = [];
end

end


