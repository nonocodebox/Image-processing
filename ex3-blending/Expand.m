function [ bigImage ] = Expand(inImage, filter)
%EXPAND expends image by zero padding and bluring with 2*filter.

try
    narginchk(2, 2);
    nargoutchk(0, 1);
    
    image_size = size(inImage);
    rows = image_size(1);
    cols = image_size(2);

    bigImg  = zeros(rows*2, cols*2);
    bigImg(1:2:end, 1:2:end) = inImage;

    bigImg = conv2(bigImg, 2*filter, 'same');
    bigImage = conv2(bigImg, 2*(filter'), 'same');
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    bigImage = [];
    return;
end

end

